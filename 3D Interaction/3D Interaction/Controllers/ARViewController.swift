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

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var objects: Results<object>?
    let realm = try! Realm()

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
//        // Show Debug Options selected
//        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin]
        
        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
//        sceneView.scene = scene
        
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()

        if let imgToTrack = ARReferenceImage.referenceImages(inGroupNamed: "Recognition", bundle: Bundle.main) {
            configuration.trackingImages = imgToTrack
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
//        let newNode = SCNNode()
        
    }
    
    // MARK: - Realm Data Manipulation
    func loadData() {
        objects = realm.objects(object.self)
    }
    
    func saveData(_ objectToAdd: object) {
        do {
            try realm.write {
                realm.add(objectToAdd)
            }
        } catch {
            print("Error saving context: \(error)")
        }
    }
}
