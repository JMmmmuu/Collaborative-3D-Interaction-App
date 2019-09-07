//
//  ViewController.swift
//  3D Interaction
//
//  Created by Yuseok on 03/09/2019.
//  Copyright © 2019 Yuseok. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import RealmSwift

class ViewController: UIViewController, ARSCNViewDelegate, UIGestureRecognizerDelegate {
    
    var objects: Results<object>?
    let realm = try! Realm()
    var originSet: Bool = false
    let MAXIMUM_OBJECT_NUMBER: Int = 30
    var objCount: Int = 0       // identifier for each object
    
    var selectedRoom: roomInfo? {
        willSet {
            self.navigationItem.title = newValue?.title
        }
    }
    var selectedObject: object?
    var selectedNode: SCNNode? {
        willSet {
            // update selectedObject when node is selected at tapGestureRecognizer
            for obj in selectedRoom!.objects {
                if let node = newValue {
                    if obj.name == node.name {
                        selectedObject = obj
                    }
                }
            }
        }
    }

    var panningWithLongPress: Bool = false
    var anchorTransform: simd_float4x4?

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
//        // Show Debug Options selected
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        sceneView.autoenablesDefaultLighting = true
        
        
        // Touch Gestures
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        sceneView.addGestureRecognizer(panGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 1.5
        sceneView.addGestureRecognizer(longPressGesture)
        longPressGesture.delegate = self
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation))
        sceneView.addGestureRecognizer(rotationGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        sceneView.addGestureRecognizer(pinchGesture)
    }
    
    
    let configuration = ARWorldTrackingConfiguration()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration

        if let imgToTrack = ARReferenceImage.referenceImages(inGroupNamed: "Recognition", bundle: Bundle.main) {
            configuration.detectionImages = imgToTrack
            configuration.maximumNumberOfTrackedImages = 1
        }
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        if anchor is ARImageAnchor {
            // Show Debug Options selected
            print("Iamge Detected")
            originSet = true
            
            sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin]
            print(anchor.transform)
            anchorTransform = anchor.transform
            
        }
        
        return node
    }

    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        if !originSet {
            print("No Origin")
            return
        }
        if objCount > MAXIMUM_OBJECT_NUMBER {
            print("Too many objects!")
            return
        }
        
        let newNode = SCNNode()
        newNode.geometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.1)
        newNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        newNode.position = SCNVector3(0, 0, 0)
        newNode.simdLocalTranslate(by: simd_make_float3((anchorTransform?.columns.3)!))
        //print(anchorTransform?.columns.3)
        
        let newObj = object(name: "\(objCount)", geomeryType: "Box")
        objCount += 1
        saveData(newObj)
        
        sceneView.scene.rootNode.addChildNode(newNode)
    }
    
    // MARK: - Realm Data Manipulation
    func loadData() {
        objects = realm.objects(object.self)
        
        // place objects on the ARWorld
        if let Objects = objects {
            for obj in Objects {
                let node = SCNNode()
                
                // Shape & Scale
                let size: CGFloat = CGFloat(0.1 * obj.scale)
                node.geometry = SCNBox(
                width: size, height: size,
                length: size, chamferRadius: size)
                
                // Rotation Angle
                node.eulerAngles = SCNVector3(obj.angleAtOrigin_x, obj.angleAtOrigin_y, obj.angleAtOrigin_z)
                
                // Position
                node.position = SCNVector3(obj.x, obj.y, obj.z)
                
                
                sceneView.scene.rootNode.addChildNode(node)
            }
            
        }
    }
    
    func saveData(_ objectToAdd: object) {
        if let room = selectedRoom {
            do {
                try realm.write {
                    realm.add(objectToAdd)
                    room.objects.append((objectToAdd))
                }
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    func deleteData(_ objToDelete: object) {
        do {
            try realm.write {
                realm.delete(objToDelete)
            }
        } catch {
            print("Error occured deleting data: \(error)")
        }
    }
    
    func updateData(with objToUpdate: object) {
        guard let changeTo = selectedObject else { return }
        do {
            try realm.write {
                objToUpdate.x = changeTo.x
                objToUpdate.y = changeTo.y
                objToUpdate.z = changeTo.z
                
                objToUpdate.angleAtOrigin_x = changeTo.angleAtOrigin_x
                objToUpdate.angleAtOrigin_y = changeTo.angleAtOrigin_y
                objToUpdate.angleAtOrigin_z = changeTo.angleAtOrigin_z
            }
        } catch {
            print("Error occured updating data: \(error)")
        }
    }
    
    
    
    // MARK: - Touch Gestures
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UILongPressGestureRecognizer && otherGestureRecognizer is UIPanGestureRecognizer {
            print("hahahah")
            return true
        }
        return false
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        print("Tap Detected")
        
        let areaTapped = sender.view as! SCNView
        let tappedCoordinates = sender.location(in: areaTapped)
        let hitTest = areaTapped.hitTest(tappedCoordinates)
        
        if hitTest.isEmpty {
            // if there's selected object, deselect it
            print("There's no object tapped")
            selectedNode = nil
        } else {
            // Tap proper object
            // check whether the object is already selected
            let resultNode = hitTest.first!.node
            if selectedNode != nil {
                // if there's selected object, and tap the other object, then deselect it
                if selectedNode == resultNode {
                    selectedNode = nil
                } else {
                    selectedNode = resultNode
                }
            } else {
                // no selected object, then select it
                selectedNode = resultNode
            }
        }
    }
    
    var x_previous: CGFloat = 0
    var y_previous: CGFloat = 0
    @objc func handlePan(sender: UIPanGestureRecognizer) {
//        print("Pan Detected")
        guard let selected = selectedNode else { return }
        
//        let location = sender.location(in: view)  // of where touch started
        let translation = sender.translation(in: view)  // How far the pan gesture moves in the x-, y- axes of screen
        

        if sender.state == .began {
            print("started")
            x_previous = translation.x
            y_previous = translation.y
        } else if sender.state == .changed {
            let x_changed = translation.x - x_previous
            let y_changed = translation.y - y_previous
            print("\(x_changed), \(y_changed)")
            
            if sender.numberOfTouches == 1 {
                if panningWithLongPress {
                    // move along z axis
                    print("Moving on z-axis")
                    selected.localTranslate(by: SCNVector3(0, 0, x_changed / 10000))
                } else {
                    // move on xy plane
                    if sender.numberOfTouches == 1 {
                        print("Moving on xy plane")
                        selected.localTranslate(by: SCNVector3(x_changed / 10000, -y_changed / 10000, 0))
                    }
                }
            } else {
                // rotate along x-axis(up/down) & y-axis(left/right)
                print("Rotating along x-, y-axis")
            }
        }
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
        print("LongPress Detected")
        if selectedNode == nil { return }
        if sender.state == .began {
            print("Long Pressed")
            panningWithLongPress = true
        } else if sender.state == .ended {
            panningWithLongPress = false
        }
    }

    @objc func handleRotation(sender: UIRotationGestureRecognizer) {
        print("Rotation Detected")
        if selectedNode == nil { return }
        
        // rotate object along z-axis
        let rotation = sender.rotation
        let velocity = sender.velocity
        
        if sender.state == .changed {
            print("rotation: \(rotation), velocity: \(velocity)")
        }
    }
    
    var scale_previous: CGFloat = 0
    let MIN_SCALE: Float = 0.01
    let MAX_SCALE: Float = 10
    @objc func handlePinch(sender: UIPinchGestureRecognizer) {
//        print("Pinch Detected")
        guard let selected = selectedNode else { return }
        
        // pinch in/ out to scale the object
        let scale = sender.scale
        print(scale)
        
        if sender.state == .began {
            scale_previous = scale
        }
        if sender.state == .changed {
            let changed_scale = Float(scale - scale_previous) / 50
            var willChange = selected.scale.x + changed_scale
            if willChange < MIN_SCALE {
                willChange = MIN_SCALE
            } else if willChange > MAX_SCALE {
                willChange = MAX_SCALE
            }
            print(willChange)
            selected.scale = SCNVector3(willChange, willChange, willChange)
        }
    }
    
}
