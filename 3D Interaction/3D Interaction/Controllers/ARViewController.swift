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

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
//        // Show Debug Options selected
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin]
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
//        let configuration = ARImageTrackingConfiguration()
        let configuration = ARWorldTrackingConfiguration()

        if let imgToTrack = ARReferenceImage.referenceImages(inGroupNamed: "Recognition", bundle: Bundle.main) {
            configuration.detectionImages = imgToTrack
//            configuration.trackingImages = imgToTrack
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
            sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin]
            print("Iamge Detected")
            originSet = true
            
            
//            let plane = SCNPlane()
//
//            let planeNode = SCNNode()
//            planeNode.eulerAngles.x = -.pi / 2
//            node.addChildNode(planeNode)
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
            panningWithLongPress = true
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
            print("There's no object tapped")
            
            // if there's selected object, deselect it
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
    
    @objc func handlePan(sender: UIPanGestureRecognizer) {
        print("Pan Detected")
        if selectedNode == nil { return }
        
//        let location = sender.location(in: view)  // of where touch started
        let velocity = sender.velocity(in: view)
        let translation = sender.translation(in: view)  // How far the pan gesture moves in the x-, y- axes of screen
        
        if sender.numberOfTouches == 1 {
            if sender.state == .changed {
                if panningWithLongPress {
                    // move along z axis
                } else {
                    // move on xy plane
                    print("Changing on xy plane")
                    print("Velocity: \(velocity), Translation: \(translation)")
                }
            }
        } else {
            // rotate along x-axis(up/down) & y-axis(left/right)
            if sender.state == .changed {
                // update angle
                print("Rotating along axis")
                print("Velocity: \(velocity), Translation: \(translation)")
                
            }
        }
        
        if sender.state == .ended {
            panningWithLongPress = false
        }
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
        print("LongPress Detected")
        if selectedNode == nil { return }
        
        print("Long Pressed")
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
    
    @objc func handlePinch(sender: UIPinchGestureRecognizer) {
        print("Pinch Detected")
        if selectedNode == nil { return }
        
        // pinch in/ out to scale the object
        let scale = sender.scale
        let velocity = sender.velocity
        
        if sender.state == .changed {
            print("scale: \(scale), velocity: \(velocity)")
        }
    }
    
}
