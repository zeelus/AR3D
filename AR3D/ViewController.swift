//
//  ViewController.swift
//  AR3D
//
//  Created by Gilbert Gwizdała on 18.08.2017.
//  Copyright © 2017 Gilbert Gwizdała. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        sceneView.showsStatistics = true
        
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let tapPoint = sender.location(in: self.view)
            let viewSize = self.view.frame.size
            let testPoint = CGPoint(x: tapPoint.x / viewSize.width, y: tapPoint.y / viewSize.height)
            //let hits = self.sceneView.hitTest(testPoint, types: [.existingPlaneUsingExtent, .featurePoint])
            let hits = self.sceneView.session.currentFrame?.hitTest(testPoint, types: [.existingPlaneUsingExtent, .featurePoint]) ?? []
            print(hits.count)
            if let hit = hits.first, let anchor = hit.anchor, let node = self.sceneView.node(for: anchor) {
 
                if let s = loadNode() {
                    s.position = SCNVector3(x: 0, y: 0, z: 0)
                    node.addChildNode(s)
                }
                
            }
        
        }
    }
    
    func loadNode() -> SCNNode? {
        
        let scene = SCNScene(named: "art.scnassets/Stormtrooper.scn")
        let node = scene?.rootNode
        node?.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        node?.scale = SCNVector3(0.5, 0.5, 0.5)
        return node
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    

//     Override to create and configure nodes for anchors added to the view's session.
//    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
//        guard let planeAncher = anchor as? ARPlaneAnchor else { return nil}
//        let node = self.sceneView.node(for: planeAncher)
//        return nil
//    }
    
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // This visualization covers only detected planes.
        
        if let planeAnchor = anchor as? ARPlaneAnchor {
            
            print(planeAnchor)
        
            // Create a SceneKit plane to visualize the node using its position and extent.
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            let mat = SCNMaterial()
            mat.diffuse.contents = UIImage(named:"grid")
            mat.locksAmbientWithDiffuse = true
            plane.materials = [mat]
            let planeNode = SCNNode(geometry: plane)
            print("add node")
            planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)
            
            // SCNPlanes are vertically oriented in their local coordinate space.
            // Rotate it to match the horizontal orientation of the ARPlaneAnchor.
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
            
            // ARKit owns the node corresponding to the anchor, so make the plane a child node.
            node.addChildNode(planeNode)
            node.name = "planeNode"
        }
        
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
}


