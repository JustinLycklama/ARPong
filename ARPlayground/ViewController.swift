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

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, SCNSceneRendererDelegate {

    @IBOutlet var ARSceneView: ARSCNView!
    var simSceneView: SCNView?
    
    var planesMap = [UUID : Plane]()
    
    var beams: [LightFragment]?
    
    let arena = Arena(withOrigin: SCNVector3.init())
    
    let configuration = ARWorldTrackingConfiguration()
    
    let newNode = SCNNode()
    
    let phoneBackPlaneNode = SCNNode()

    let scene = SCNScene()
    
    let phoneDirectionNode = LightFragment(startPoint: SCNVector3(0, 0, 0.1), endPoint: SCNVector3(0.2, 0.1, 0), radius: 0.005, color: .yellow)
    
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
            
            
            // 2
//            let boxGeometry = SCNBox(width: 10.0, height: 10.0, length: 10.0, chamferRadius: 1.0)
//            let boxNode = SCNNode(geometry: boxGeometry)
            
            
            scene.rootNode.addChildNode(arena)
            
            // 3
            simSceneView?.scene = scene
            simSceneView?.delegate = self
            
            
            
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
            
            
            
//            let sphereGeo = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.0)
//
//            newNode.position = SCNVector3(0, 0, -0.3)
//            newNode.geometry = sphereGeo
//
////                    sceneView.scene.rootNode.addChildNode(newNode)
//            ARSceneView.pointOfView?.addChildNode(newNode)
            
            
            let backPlaneGeo = SCNPlane(width: 0.1, height: 0.1)
            
            let material = SCNMaterial()
            material.isDoubleSided = true

            backPlaneGeo.materials = [material]
            
            phoneBackPlaneNode.position = SCNVector3(0, 0, -0.3)
            phoneBackPlaneNode.geometry = backPlaneGeo

            
            ARSceneView.scene = scene
            
            scene.rootNode.addChildNode(phoneBackPlaneNode)
            
            scene.rootNode.addChildNode(arena)
            
            arena.addChildNode(phoneDirectionNode)
            
            
            
//            if let pointOfView = ARSceneView.pointOfView {
//                print(pointOfView.frame)
//            }
            
            self.ARSceneView.debugOptions = [SCNDebugOptions.showWorldOrigin, SCNDebugOptions.showFeaturePoints]
            self.ARSceneView.automaticallyUpdatesLighting = true // Supposedly makes detecting faster
        

        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Platform.isSimulator {
            simSceneView?.isPlaying = true
        } else {
            // Create a session configuration
//            configuration.planeDetection = [.horizontal]
            
            // Run the view's session
            ARSceneView.session.delegate = self
            ARSceneView.session.run(configuration)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if Platform.isSimulator {
            simSceneView?.isPlaying = false
        } else {
        
            // Pause the view's session
            ARSceneView.session.pause()
        }
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
        if let parentForwardDirection = ARSceneView.pointOfView?.parentFront,
            let parentPosition = ARSceneView.pointOfView?.position {
            let newVec = arena.convertVector(parentForwardDirection, from: ARSceneView.pointOfView?.parent)
            let newPos = arena.convertPosition(parentPosition, from: ARSceneView.pointOfView?.parent)
            
            phoneDirectionNode.update(startPoint: newPos + (newVec.normalized * 0.1), endPoint: newPos + newVec.normalized * 0.2)
            
            NSLog(String(newVec.x), String(newVec.y), String(newVec.z))
        }
        
        if  let parentNode = ARSceneView.pointOfView?.parent,
            let position = ARSceneView.pointOfView?.position,
            let transform = ARSceneView.pointOfView?.transform {
            

//            phoneBackPlaneNode.position = SCNVector3Zero

//            phoneBackPlaneNode.transform = transform
//
//            phoneBackPlaneNode.position = position - SCNVector3(0, 0, 0.3)


            
            
            
            

//            let newTrans = parentNode.convertTransform(transform, to: arena)
//            phoneDirectionNode.transform = transform
//
//            let newPos = parentNode.convertPosition(position, to: scene.rootNode)
//            phoneBackPlaneNode.position = newPos - SCNVector3(0, 0, 0.3)
        }
        
//        setupBeams(aFrame: frame)
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
    
    var lastUpdateDate: TimeInterval?
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        guard let last = lastUpdateDate else {
            lastUpdateDate = time
            return
        }
        
        let delta = time - last
        arena.update(deltaTime: delta)
        
        lastUpdateDate = time
    }
    
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
