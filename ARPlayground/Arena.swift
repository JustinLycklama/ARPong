//
//  Arena.swift
//  ARPlayground
//
//  Created by Justin Lycklama on 2018-11-26.
//  Copyright © 2018 Justin Lycklama. All rights reserved.
//

import UIKit
import ARKit

struct CollisionData {
    let point: SCNVector3
    let reflectedDirection: SCNVector3
}

class Arena: SCNNode {

//    private var anchor: ARPlaneAnchor
    
//    private let position: SCNVector3
    private var planes: [SCNNode] = []
    
    let lightNode: Light
    
    init(withOrigin origin: SCNVector3) {
        
        lightNode = Light(initialPosition: SCNVector3(0, 0.3 / 2.0, 0), direction: SCNVector3(0.5, 1, 0.5))
        
        super.init()
        
        // X, Y, Z
        let dimensions: SCNVector3 = SCNVector3(1, 0.3, 0.3)
        
        let createPlane = { (width: Float, height: Float) -> SCNNode in
            
            let planeGeometry = SCNPlane(width: CGFloat(width), height: CGFloat(height))
            
            let planeNode = SCNNode(geometry: planeGeometry)

            let material = SCNMaterial()
            material.diffuse.contents = UIImage(named: "tron_grid")
            material.isDoubleSided = true
            
            planeGeometry.materials = [material]
            
            return planeNode
        }
        
        // Floor
        let floor = createPlane(dimensions.x, dimensions.z)
        floor.transform = SCNMatrix4MakeRotation(Float(-Double.pi / 2.0), 1.0, 0.0, 0.0)
        floor.position = SCNVector3(origin.x, origin.y, origin.z)

        
        planes.append(floor)
        addChildNode(floor)
        
        // Roof
        let roof = createPlane(dimensions.x, dimensions.z)
        roof.transform = SCNMatrix4MakeRotation(Float(-Double.pi / 2.0), 1.0, 0.0, 0.0)
        roof.position = SCNVector3(origin.x, origin.y + dimensions.y, origin.z)
        
        planes.append(roof)
        addChildNode(roof)
        
        // Left Wall
        let leftWall = createPlane(dimensions.z, dimensions.y)
        leftWall.transform = SCNMatrix4MakeRotation(Float(-Double.pi / 2.0), 0.0, 1.0, 0.0)
        leftWall.position = SCNVector3(origin.x - (dimensions.x / 2.0), origin.y + (dimensions.y / 2.0), origin.z)

        planes.append(leftWall)
        addChildNode(leftWall)
        
        let leftWallNorm = LightFragment(startPoint: leftWall.position, endPoint: leftWall.position + leftWall.parentFront.normalized * 0.1, radius: 0.005, color: .yellow)
        
        addChildNode(leftWallNorm)

        
        // Right Wall
        let rightWall = createPlane(dimensions.z, dimensions.y)
        rightWall.transform = SCNMatrix4MakeRotation(Float(-Double.pi / 2.0), 0.0, 1.0, 0.0)
        rightWall.position = SCNVector3(origin.x + (dimensions.x / 2.0), origin.y + (dimensions.y / 2.0), origin.z)
        
        planes.append(rightWall)
        addChildNode(rightWall)
        
        // Far Wall
        let farWall = createPlane(dimensions.x, dimensions.y)
        farWall.position = SCNVector3(origin.x, origin.y + (dimensions.y / 2.0), origin.z - (dimensions.z / 2.0))
        
        planes.append(farWall)
        addChildNode(farWall)
        
        // Close Wall
        let closeWall = createPlane(dimensions.x, dimensions.y)
        closeWall.position = SCNVector3(origin.x, origin.y + (dimensions.y / 2.0), origin.z + (dimensions.z / 2.0))
        
        planes.append(closeWall)
        addChildNode(closeWall)
        
        // Beam
        addChildNode(lightNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    
    public func update(deltaTime: TimeInterval, phonePlane: PlaneConstruction?) {
        let speed: Float = 0.75
        
        lightNode.updateKeyFrames(movement: speed * Float(deltaTime))
        
        if let fragment = lightNode.getLeadingFragment() {
            for plane in planes {
                let planeConstruction = PlaneConstruction(position: plane.position, normal: plane.parentFront, width: 0 , height: 0)
                if let collisionInfo = collision(plane: planeConstruction, a: fragment.startKeyFrame.position, b: fragment.endKeyFrame.position) {
                    NSLog("Collision")
                    
                    lightNode.createNewFragment(cutPosition: collisionInfo.point, direction: collisionInfo.reflectedDirection)
                    break
                }
            }
            
            if let plane = phonePlane,
                let collisionInfo = collision(plane: plane, a: fragment.startKeyFrame.position, b: fragment.endKeyFrame.position) {
                NSLog("Phone Collision")
                
                lightNode.createNewFragment(cutPosition: collisionInfo.point, direction: collisionInfo.reflectedDirection)
                
                DispatchQueue.main.async { [weak self] in
                    self?.feedbackGenerator.impactOccurred()
                }
            }
        }
        
        lightNode.updateFragments()
    }

    
    private func collision(plane: PlaneConstruction, a: SCNVector3, b: SCNVector3) -> CollisionData? {
        let planePoint = plane.position
        let planeNormal = plane.normal
        
        let planeNormalDotLineDirection = planeNormal.dotProduct(b - a)
        if planeNormalDotLineDirection == 0 {
            return nil
        }
        
        let t = (planeNormal.dotProduct(planePoint) - planeNormal.dotProduct(a)) / planeNormalDotLineDirection
        
        if t >= 0 && t <= 1 {
            let collisionPoint = a + ((b - a) * t)
            
            let I = a - b // Inverse direction of incoming ray
        
            let NDotI = planeNormal.dotProduct(I)
            let reflectedRay = (planeNormal * 2 * NDotI) - I

            return CollisionData(point: collisionPoint, reflectedDirection: reflectedRay.normalized)
        }
    
        
        return nil
    }
}

