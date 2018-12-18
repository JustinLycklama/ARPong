//
//  Arena.swift
//  ARPlayground
//
//  Created by Justin Lycklama on 2018-11-26.
//  Copyright © 2018 Justin Lycklama. All rights reserved.
//

import UIKit
import ARKit

class Player {
    var phone: PlaneConstruction
    
    init(width: SCNFloat, height: SCNFloat) {
        phone = PlaneConstruction(position: SCNVector3Zero, normal: SCNVector3Zero, width: 0, height: 0)
    }
    
    public func update(position: SCNVector3, direction: SCNVector3) {
        phone.update(position: position, normal: direction)
    }
}

struct CollisionData {
    let point: SCNVector3
    let reflectedDirection: SCNVector3
    let planeConstrutcion: PlaneConstruction
    
    init(point: SCNVector3, reflectedDirection: SCNVector3, plane: PlaneConstruction) {
        self.point = point
        self.reflectedDirection = reflectedDirection.normalized
        self.planeConstrutcion = plane
    }
}

class Arena: SCNNode {

//    private var anchor: ARPlaneAnchor
    
//    private let position: SCNVector3
    private var planes: [SCNNode] = []
    
    let lightNode: Light
    
    let player: Player
    
    init(withOrigin origin: SCNVector3, player: Player) {
        
        self.player = player
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
    
    public func update(deltaTime: TimeInterval) {
        let ceil: Float = 0.05
        let speed: Float = 1.00
        
        // Don't let movement get too crazy
        let movement = min(ceil, speed * Float(deltaTime))
        
        lightNode.updateKeyFrames(movement: movement)
        
        if let fragment = lightNode.getLeadingFragment() {
            
            var collisionInfo: CollisionData? = checkAllCollisions(withSegmentFrom: fragment.startKeyFrame.position, b: fragment.endKeyFrame.position)
            var continuedCollisionInfo: CollisionData? = collisionInfo
            
            // Don't get caught in infinite loop
            var repeats: Int = 0
            let repeatMax = 5
            
            while continuedCollisionInfo != nil && repeats < repeatMax {
                // We have a collision. Check if the collision's new start point is 'skipping over' any planes it should have collided with
                
                collisionInfo = continuedCollisionInfo
                
                if let info = collisionInfo {
                    continuedCollisionInfo = checkAllCollisions(withSegmentFrom: info.point - (info.reflectedDirection * Light.standardErrorOffset),
                                                                b: info.point + (info.reflectedDirection * Light.standardErrorOffset),
                                                                ignoringPlane: info.planeConstrutcion)
                }
                
                repeats += 1
            }
            
            if repeats == repeatMax {
                NSLog("Hit the max collision bounce count")
                exit(0)
            }
            
            if let info = collisionInfo {
                lightNode.createNewFragment(cutPosition: info.point + (info.reflectedDirection * Light.standardErrorOffset), direction: info.reflectedDirection)
            }
        }
        
        lightNode.updateFragments()
    }
    
    private func checkAllCollisions(withSegmentFrom a: SCNVector3, b: SCNVector3, ignoringPlane: PlaneConstruction? = nil) -> CollisionData? {
        var savedCollisionInfo: CollisionData? = nil

        let addToInfo = { (info: CollisionData) in
            
            if let oldInfo = savedCollisionInfo {
                NSLog("lol")
//                let newDirection = oldInfo.planeConstrutcion.normal + info.planeConstrutcion.normal
//                savedCollisionInfo = CollisionData(point: oldInfo.point,
//                                                   reflectedDirection: newDirection,
//                                                   plane: PlaneConstruction(position: SCNVector3Zero, normal: newDirection, width: 0, height: 0))
            } else {
//                savedCollisionInfo = info
            }
            
            savedCollisionInfo = info

        }
        
        for plane in planes {
            if plane.parentFront == ignoringPlane?.normal {
                continue
            }
            
            let planeConstruction = PlaneConstruction(position: plane.position, normal: plane.parentFront, width: 0 , height: 0)
            if let collisionInfo = collision(plane: planeConstruction, a: a, b: b) {
                addToInfo(collisionInfo)
                
                NSLog("Collision")
            }
        }
        
        if !(player.phone.normal == ignoringPlane?.normal),
            let collisionInfo = collision(plane: player.phone, a: a, b: b) {
            addToInfo(collisionInfo)
            
            NSLog("Phone Collision")

            DispatchQueue.main.async { [weak self] in
                self?.feedbackGenerator.impactOccurred()
            }
        }
        
        return savedCollisionInfo
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

            return CollisionData(point: collisionPoint, reflectedDirection: reflectedRay.normalized, plane: plane)
        }
    
        
        return nil
    }
}

