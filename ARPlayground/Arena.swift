//
//  Arena.swift
//  ARPlayground
//
//  Created by Justin Lycklama on 2018-11-26.
//  Copyright © 2018 Justin Lycklama. All rights reserved.
//

import UIKit
import ARKit

class Arena: SCNNode {

//    private var anchor: ARPlaneAnchor
    
//    private let position: SCNVector3
    private var planes: [SCNNode] = []
        
    init(withOrigin origin: SCNVector3) {
        
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
 
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
