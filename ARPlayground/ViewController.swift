//
//  ViewController.swift
//  ARPlayground
//
//  Created by Justin Lycklama on 2018-11-06.
//  Copyright © 2018 Justin Lycklama. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

struct Platform {
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
}

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var ARSceneView: ARSCNView!
    var simSceneView: SCNView?
    
    var planesMap = [UUID : Plane]()
    
    var beams: [LightFragment]?
    
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Platform.isSimulator {
            
            
            simSceneView = SCNView()
//            simSceneView!.scene = _level
            simSceneView!.allowsCameraControl = true
            simSceneView!.showsStatistics = true
            simSceneView!.backgroundColor = .black
            simSceneView!.debugOptions = .showWireframe
            simSceneView!.autoenablesDefaultLighting = true
            self.view = simSceneView
            
            let scene = SCNScene()
            
            // 2
//            let boxGeometry = SCNBox(width: 10.0, height: 10.0, length: 10.0, chamferRadius: 1.0)
//            let boxNode = SCNNode(geometry: boxGeometry)
            
            let arenaNode = Arena(withOrigin: SCNVector3.init())

            let lightNode = Light(initialPosition: SCNVector3(0, 0.3 / 2.0, 0), direction: SCNVector3(1, 0, 0))
            
            scene.rootNode.addChildNode(arenaNode)
            scene.rootNode.addChildNode(lightNode)
            
            // 3
            simSceneView?.scene = scene
            
            
            
        } else {
            // Set the view's delegate
            ARSceneView.delegate = self
            
            // Show statistics such as fps and timing information
            ARSceneView.showsStatistics = true
            
            // Create a new scene
            //        let scene = SCNScene(named: "art.scnassets/ship.scn")!
            //
            //        // Set the scene to the view
            //        sceneView.scene = scene
            
            
            
            let newNode = SCNNode()
            let sphereGeo = SCNSphere(radius: 0.015)
            
            newNode.position = SCNVector3(0, 0, -0.3)
            newNode.geometry = sphereGeo
            
            //        sceneView.scene.rootNode.addChildNode(newNode)
            ARSceneView.pointOfView?.addChildNode(newNode)
            
            if let pointOfView = ARSceneView.pointOfView {
                print(pointOfView.frame)
            }
            
            self.ARSceneView.debugOptions = [SCNDebugOptions.showWorldOrigin, SCNDebugOptions.showFeaturePoints]
            self.ARSceneView.automaticallyUpdatesLighting = true // Supposedly makes detecting faster
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Platform.isSimulator {
            NSLog("Hello!")
        } else {
            // Create a session configuration
            configuration.planeDetection = [.horizontal]
            
            // Run the view's session
            ARSceneView.session.delegate = self
            ARSceneView.session.run(configuration)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        ARSceneView.session.pause()
    }
    
    func setupBeams(aFrame frame: ARFrame) {
        if beams != nil {
            return
        }
        
//        let imageResolution = frame.camera.imageResolution
//        let viewSize = sceneView.bounds.size
//        let projection = frame.camera.projectionMatrix(for: .portrait,
//                                                       viewportSize: viewSize, zNear: 1, zFar: 2)
//        let yScale = projection[1,1] // = 1/tan(fovy/2)
//        let yFovDegrees = 2 * atan(1/yScale) * 180/Float.pi
//        let xFovDegrees = yFovDegrees * Float(viewSize.height / viewSize.width)
        
        
        let projection = frame.camera.projectionMatrix
        let yScale = projection[1,1]
        let yFov = 2 * atan(1/yScale) // in radians
        let yFovDegrees = yFov * 180/Float.pi
        
        let imageResolution = frame.camera.imageResolution
        let xFov = yFov * Float(imageResolution.width / imageResolution.height)
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        setupBeams(aFrame: frame)
    }
    
    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    
    var highlightedPlane: Plane? = nil
    
    /**
     Called when a new node has been mapped to the given anchor.
     @param renderer The renderer that will render the scene.
     @param node The node that maps to the anchor.
     @param anchor The added anchor.
     */
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor: ARPlaneAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        
//        let newNode = SCNNode()
//        let sphereGeo = SCNSphere(radius: 0.025)
//
//        newNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
//        newNode.geometry = sphereGeo
//
//        node.addChildNode(newNode)

        
        
        // ----
        
//        let newPlane = Plane(anchor: planeAnchor)
//
//        node.addChildNode(newPlane)
//        planesMap[planeAnchor.identifier] = newPlane
//
//        highlightedPlane?.deselect()
//
//        newPlane.highlight()
//        highlightedPlane = newPlane
        
        // 0----
        
        let newArena = Arena(withOrigin: SCNVector3(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z))
        node.addChildNode(newArena)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
//        if let plane = planesMap[anchor.identifier],
//            let planeAnchor: ARPlaneAnchor = anchor as? ARPlaneAnchor {
//            plane.update(anchor: planeAnchor)
//
//            highlightedPlane?.deselect()
//
//            plane.highlight()
//            highlightedPlane = plane
//        }
    }
}
