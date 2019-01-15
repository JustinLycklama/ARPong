//
//  Plane.swift
//  ARPlayground
//
//  Created by Justin Lycklama on 2018-11-06.
//  Copyright © 2018 Justin Lycklama. All rights reserved.
//

import UIKit
import ARKit

class LSPlane: SCNNode {

    private var planeGeometry: SCNPlane
    
    public var width: CGFloat {
        get  {
            return planeGeometry.width
        }
    }
    
    public var height: CGFloat {
        get {
            return planeGeometry.height
        }
    }
    
    public var heightVector: SCNVector3 {
        get {
            return self.parentUp.normalized * SCNFloat(planeGeometry.height)
        }
    }
    
    public var widthVector: SCNVector3 {
        get {
            return self.parentRight.normalized * SCNFloat(planeGeometry.width)
        }
    }
    
    // Creates a vertical plane, where width is the x-dimension and height is the y-dimension
    init(width: CGFloat, height: CGFloat) {
        planeGeometry = SCNPlane(width: width, height: height)
        super.init()
        
        self.geometry = planeGeometry
        
        // Tron material
        let material = SCNMaterial()

        material.diffuse.contents = UIImage(named: "tron_grid")
        planeGeometry.materials = [material]
        material.isDoubleSided = true

        
        // Planes in SceneKit are vertical by default so we need to rotate 90degrees to match
        // planes in ARKit
//        planeNode.transform = SCNMatrix4MakeRotation(Float(-Double.pi / 2.0), 1.0, 0.0, 0.0)
//
//        addChildNode(planeNode)
        

        
        let normalVector = LightFragment(startPoint: self.position,
                               endPoint: self.parentFront.normalized * 0.1,
                               radius: 0.025,
                               color: .red)

        addChildNode(normalVector)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
