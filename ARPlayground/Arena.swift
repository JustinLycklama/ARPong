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
        phone = PlaneConstruction(position: SCNVector3Zero, normal: SCNVector3Zero, width: 0.1, height: 0.1)
    }
    
    public func update(position: SCNVector3, direction: SCNVector3) {
        phone.update(position: position, normal: direction)
    }
}

struct CollisionData {
    let point: SCNVector3
    let originalDirection: SCNVector3
    let reflectedDirection: SCNVector3
    let planeConstrutcion: PlaneConstruction
    let tVaule: SCNFloat
    
    init(point: SCNVector3, originalDirection: SCNVector3, reflectedDirection: SCNVector3, plane: PlaneConstruction, tval: SCNFloat) {
        self.point = point
        self.originalDirection = originalDirection
        self.reflectedDirection = reflectedDirection.normalized
        self.planeConstrutcion = plane
        self.tVaule = tval
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
        let speed: Float = 0.15
        
        // Don't let movement get too crazy
        let movement = min(ceil, speed * Float(deltaTime))
        
        lightNode.updateKeyFrames(movement: movement)
        
        if let fragment = lightNode.getLeadingFragment() {
            
            var collisionInfo: CollisionData? = checkAllCollisions(withSegmentFrom: fragment.startKeyFrame.position, to: fragment.endKeyFrame.position)
            var continuedCollisionInfo: CollisionData? = collisionInfo
            
            // Don't get caught in infinite loop
            var repeats: Int = 0
            let repeatMax = 5
            
            while continuedCollisionInfo != nil && repeats < repeatMax {
                // We have a collision. Check if the collision's new start point is 'skipping over' any planes it should have collided with
                
                collisionInfo = continuedCollisionInfo
                
                if let info = collisionInfo {
                    continuedCollisionInfo = checkAllCollisions(withSegmentFrom: info.point - (info.originalDirection * (Light.standardErrorOffset * 3)),
                                                                to: info.point + (info.reflectedDirection * (Light.standardErrorOffset * 3)),
                                                                ignoringPlane: info.planeConstrutcion)
                }
                
                repeats += 1
            }
            
            if repeats == repeatMax {
                NSLog("Hit the max collision bounce count")
                exit(0)
            }
            
            if let info = collisionInfo {
                lightNode.createNewFragment(cutPosition: info.point - (info.originalDirection * Light.standardErrorOffset),
                                            newFragPosition: info.point + (info.reflectedDirection * Light.standardErrorOffset),
                                            direction: info.reflectedDirection)
            }
        }
        
        lightNode.updateFragments()
    }
    
    private func checkAllCollisions(withSegmentFrom a: SCNVector3, to b: SCNVector3, ignoringPlane: PlaneConstruction? = nil) -> CollisionData? {
        var savedCollisionInfo: CollisionData? = nil

        var collisionDataList = [CollisionData]()
        
        let addToInfo = { (info: CollisionData) in
            
            collisionDataList.append(info)
            
//            if let oldInfo = savedCollisionInfo {
//                NSLog("lol")
////                let newDirection = oldInfo.planeConstrutcion.normal + info.planeConstrutcion.normal
////                savedCollisionInfo = CollisionData(point: oldInfo.point,
////                                                   reflectedDirection: newDirection,
////                                                   plane: PlaneConstruction(position: SCNVector3Zero, normal: newDirection, width: 0, height: 0))
//            } else {
////                savedCollisionInfo = info
//            }
//
//            savedCollisionInfo = info

        }
        
        for plane in planes {
//            if plane.parentFront == ignoringPlane?.normal {
//                continue
//            }
            
            let planeConstruction = PlaneConstruction(position: plane.position, normal: plane.parentFront, width: 0.3 , height: 0.3)
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
        
        
        // Return the closest collision
        var finalData: CollisionData? = nil
        var smallestT: SCNFloat = 1.5 // T will be less than or equal to 1
        
        for data in collisionDataList {
            if data.tVaule < smallestT {
                finalData = data
                smallestT = data.tVaule
            }
        }
        
        return finalData
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
            let collisionPoint = a + ((b - a) * t * (1 - Light.standardErrorOffset))
            
            // Now that we have our collision point, lets see if it falls within the plane construction
            let vectorToCollision = collisionPoint - plane.position
            
            if abs(vectorToCollision.dotProduct(plane.height.normalized)) > plane.height.magnitude ||
                abs(vectorToCollision.dotProduct(plane.width.normalized)) > plane.width.magnitude {
                return nil
            }
            
            let I = a - b // Inverse direction of incoming ray
        
            let NDotI = planeNormal.dotProduct(I)
            let reflectedRay = (planeNormal * 2 * NDotI) - I

            return CollisionData(point: collisionPoint, originalDirection: b - a, reflectedDirection: reflectedRay.normalized, plane: plane, tval: t)
        }
    
        return nil
    }
}

