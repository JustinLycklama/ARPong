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

public struct Platform {
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
}

protocol LSSceneDelegate {
    func requestCreateArena()
    func requestResetExperience()
}

class LSSceneViewController: UIViewController {
    let scene = SCNScene()
    
    // Mark: Simulator
    var simSceneView: SCNView = SCNView()
    
    // MARK: AR Config
    var sceneView: ARSCNView = ARSCNView()
    let configuration = ARWorldTrackingConfiguration()
    let interfaceController: LSInterfaceController

    // MARK: Objects
    let player: Player
    
    var arenaPositionInScene: SCNVector3?
    var arenaTransformInScene: SCNMatrix4?
    
    var arena: Arena?
    
    let focusSquare: FocusSquare

    fileprivate var lastUpdateDate: TimeInterval?
    
    var arenaAnchorNode: SCNNode?
    var planesMap = [UUID : LSPlane]()
    
    // MARK: Debug
    let DEBUG = false
    let phoneDirectionNode = LightFragment(startPoint: SCNVector3(0, 0, 0.1), endPoint: SCNVector3(0.2, 0.1, 0), radius: 0.005, color: .yellow)
    
    // MARK: - View Lifecycle
    required init?(coder aDecoder: NSCoder) {

        player = Player(width: 0, height: 0)
        focusSquare = FocusSquare()
        
        interfaceController = LSInterfaceController()
        
        super.init(coder: aDecoder)
        
        interfaceController.delegate = self
        interfaceController.enablePlaceArena(false)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a custom scene is we are in Sim
        if Platform.isSimulator {
            simSceneView = SCNView()
            
            simSceneView.allowsCameraControl = true
            simSceneView.showsStatistics = true
            simSceneView.backgroundColor = .black
            simSceneView.debugOptions = .showWireframe
            simSceneView.autoenablesDefaultLighting = true
            self.view = simSceneView
            
            let arena = Arena(player: player)
            
            arena.position = SCNVector3(-10, 0, 0)
            
            scene.rootNode.addChildNode(arena)
            
            self.arena = arena
            
            simSceneView.scene = scene
            simSceneView.delegate = self
            
            return
        }
        
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.scene = scene
    
        self.view = sceneView
        
        self.sceneView.debugOptions = [SCNDebugOptions.showWorldOrigin, SCNDebugOptions.showFeaturePoints]
        self.sceneView.automaticallyUpdatesLighting = true // Supposedly makes detecting faster
        
        // Setup UI
        scene.rootNode.addChildNode(focusSquare)

        self.addChild(interfaceController)
        self.view.addSubview(interfaceController.view)
        self.view.constrainSubviewToBounds(interfaceController.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Platform.isSimulator {
            simSceneView.isPlaying = true
        } else {
            // Create a session configuration
            configuration.planeDetection = [.horizontal]
            
            // Run the view's session
            sceneView.session.delegate = self
            sceneView.session.run(configuration)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if Platform.isSimulator {
            simSceneView.isPlaying = false
        } else {
        
            // Pause the view's session
            sceneView.session.pause()
        }
    }

    func updateFocusSquare() {

    }
}

// MARK: - LSSceneDelegate
extension LSSceneViewController: LSSceneDelegate {
    func requestResetExperience() {
        interfaceController.enablePlaceArena(false)
        
        arena?.removeFromParentNode()
        arena = nil
        
        arenaAnchorNode = nil

        planesMap.values.forEach { (value: LSPlane) in
            value.removeFromParentNode()
        }

        planesMap.removeAll()
    }
    
    func requestCreateArena() {
        
        requestResetExperience()
        
        let arena = Arena(player: player)
        
        if DEBUG {
            arena.addChildNode(phoneDirectionNode)
        }
        
        self.arena = arena
        
        arenaPositionInScene = player.phone.position
        arenaTransformInScene = player.phone.transform
        

        if let arenaAnchorNode = arenaAnchorNode {
            arenaAnchorNode.addChildNode(arena)
            
            
            let positionInNode = arenaAnchorNode.convertPosition(arenaPositionInScene ?? SCNVector3.init(),
                                                                 from: scene.rootNode)
            let transformInNode = arenaAnchorNode.convertTransform(arenaTransformInScene ?? SCNMatrix4.init(),
                                                                   from: scene.rootNode)
            
            arena.position = positionInNode
            arena.transform = transformInNode
        } else {
            scene.rootNode.addChildNode(arena)
            
            arena.position = arenaPositionInScene ?? SCNVector3.init()
            arena.transform = arenaTransformInScene ?? SCNMatrix4.init()
        }
    }
}

// MARK: - ARSCNViewDelegate
extension LSSceneViewController: ARSCNViewDelegate {
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
        
        if arenaAnchorNode == nil {
            arenaAnchorNode = node
            interfaceController.enablePlaceArena(true)
            
            let newPlane = LSPlane(width: 1.0, height: 1.0)
    
            newPlane.transform = SCNMatrix4MakeRotation(Float(-Double.pi / 2.0), 1.0, 0.0, 0.0)

            
            node.addChildNode(newPlane)
            planesMap[planeAnchor.identifier] = newPlane
        }
        
        // ----
        

        //
        //        highlightedPlane?.deselect()
        //
        //        newPlane.highlight()
        //        highlightedPlane = newPlane
        
        // 0----
        
        //        let newArena = Arena(withOrigin: SCNVector3(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z))
        //        node.addChildNode(newArena)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        if  let arenaAnchorNode = arenaAnchorNode,
            node == arenaAnchorNode {
            let positionInNode = arenaAnchorNode.convertPosition(arenaPositionInScene ?? SCNVector3.init(),
                                                                 from: scene.rootNode)
            let transformInNode = arenaAnchorNode.convertTransform(arenaTransformInScene ?? SCNMatrix4.init(),
                                                                   from: scene.rootNode)
            
            arena?.position = positionInNode
            arena?.transform = transformInNode
        }
        
    }
}

// MARK: - ARSessionDelegate
extension LSSceneViewController: ARSessionDelegate {
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let arena = arena else {
            return
        }
        
        if let parentForwardDirection = sceneView.pointOfView?.parentFront,
            let parentPosition = sceneView.pointOfView?.position {
            let newVec = arena.convertVector(parentForwardDirection, from: sceneView.pointOfView?.parent)
            let newPos = arena.convertPosition(parentPosition, from: sceneView.pointOfView?.parent)
            
            phoneDirectionNode.update(startPoint: newPos + (newVec.normalized * 0.1), endPoint: newPos + newVec.normalized * 0.2)
            
            
            
            //            NSLog(String(newVec.x), String(newVec.y), String(newVec.z))
        }
        
        if  let parentNode = sceneView.pointOfView?.parent,
            let position = sceneView.pointOfView?.position,
            let transform = sceneView.pointOfView?.transform {
            
            
            
            
            
            
            
            
            
            
            //            let newTrans = parentNode.convertTransform(transform, to: arena)
            //            phoneDirectionNode.transform = transform
            //
            //            let newPos = parentNode.convertPosition(position, to: scene.rootNode)
            //            phoneBackPlaneNode.position = newPos - SCNVector3(0, 0, 0.3)
        }
    }
}

// MARK: - SCNSceneRendererDelegate
extension LSSceneViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        guard let arena = arena else {
            return
        }
        
        guard let last = lastUpdateDate else {
            lastUpdateDate = time
            return
        }
        
        let delta = time - last
        
        // Update Player
        if let pointOfViewTransformation = sceneView.pointOfView?.transform,
            let parentPosition = sceneView.pointOfView?.position {
            let newTransform = arena.convertTransform(pointOfViewTransformation, from: sceneView.pointOfView?.parent)
            let newPos = arena.convertPosition(parentPosition, from: sceneView.pointOfView?.parent)
            
            player.update(position: newPos, transformation: newTransform)
        }
        
        // Update Focus Aquare
        
        if let parentTransform = sceneView.pointOfView?.transform,
            let parentPosition = sceneView.pointOfView?.position {
            let newTransform = arena.convertTransform(parentTransform, from: sceneView.pointOfView?.parent)
            let newPos = arena.convertPosition(parentPosition, from: sceneView.pointOfView?.parent)
            
            self.focusSquare.position = newPos
            self.focusSquare.transform = newTransform
            
            
            
            //            NSLog(String(newVec.x), String(newVec.y), String(newVec.z))
        }
        
        //        DispatchQueue.main.async {
        //            self.updateFocusSquare()
        //        }
        
        // Update Arena
        arena.update(deltaTime: delta)
        
        lastUpdateDate = time
    }
}
