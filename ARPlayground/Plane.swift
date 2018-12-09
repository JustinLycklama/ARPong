//
//  Plane.swift
//  ARPlayground
//
//  Created by Justin Lycklama on 2018-11-06.
//  Copyright © 2018 Justin Lycklama. All rights reserved.
//

import UIKit
import ARKit

class Plane: SCNNode {

    private var anchor: ARPlaneAnchor
    private var planeGeometry: SCNPlane
    
    
    
    init(anchor: ARPlaneAnchor) {
        self.anchor = anchor
        planeGeometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        super.init()
        
        let planeNode = SCNNode(geometry: planeGeometry)
        planeNode.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
        
        // Tron material
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "tron_grid")
        planeGeometry.materials = [material]
        
        // Planes in SceneKit are vertical by default so we need to rotate 90degrees to match
        // planes in ARKit
        planeNode.transform = SCNMatrix4MakeRotation(Float(-Double.pi / 2.0), 1.0, 0.0, 0.0)
        
        addChildNode(planeNode)
        
        // Random cyl
//        let cylinderGeometry = SCNCylinder(radius: 0.025, height: 0.025)
//        cylinderGeometry.materials = [material]
//
//        let cylinderNode = SCNNode(geometry: cylinderGeometry)
//        cylinderNode.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
//
//        cylinderNode.transform = SCNMatrix4MakeRotation(Float(-Double.pi / 2.0), 1.0, 0.0, 0.0)
//
//        addChildNode(cylinderNode)
        
        
        
        
        
        let newCylinder = LightFragment(startPoint: SCNVector3Make(anchor.center.x, 0, anchor.center.z),
                               endPoint: SCNVector3Make(anchor.center.x, 10, anchor.center.z),
                               radius: 0.025,
                               color: .red)

        addChildNode(newCylinder)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public func highlight() {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red.cgColor
        planeGeometry.materials = [material]
        

    }
    
    public func deselect() {
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "tron_grid")
        planeGeometry.materials = [material]
        
    }
    
    public func update(anchor: ARPlaneAnchor) {
        // As the user moves around the extend and location of the plane
        // may be updated. We need to update our 3D geometry to match the
        // new parameters of the plane.
        
        planeGeometry.width = CGFloat(anchor.extent.x)
        planeGeometry.height = CGFloat(anchor.extent.z)
        
        // When the plane is first created it's center is 0,0,0 and the nodes
        // transform contains the translation parameters. As the plane is updated
        // the planes translation remains the same but it's center is updated so
        // we need to update the 3D geometry position
        
        self.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
    }
}
