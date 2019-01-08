//
//  Beam.swift
//  ARPlayground
//
//  Created by Justin Lycklama on 2018-11-06.
//  Copyright © 2018 Justin Lycklama. All rights reserved.
//

import UIKit
import ARKit

class LightFragment: SCNNode {

    private var startPoint: SCNVector3
    private var endPoint: SCNVector3
    private let radius: CGFloat
    private let color: UIColor
    
    init(startPoint: SCNVector3, endPoint: SCNVector3, radius: CGFloat, color: UIColor) {
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.radius = radius
        self.color = color
        
        super.init()
    
        let cyl = SCNCylinder(radius: radius, height: 0.01)
        cyl.firstMaterial?.diffuse.contents = color
        
        self.geometry = cyl
        
        calculateTransformation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func update(startPoint: SCNVector3, endPoint: SCNVector3) {
        self.startPoint = startPoint
        self.endPoint = endPoint
        
        calculateTransformation()
    }
    
    func calculateTransformation() {
        let w = SCNVector3(x: endPoint.x-startPoint.x,
                           y: endPoint.y-startPoint.y,
                           z: endPoint.z-startPoint.z)
        
        let l = CGFloat(sqrt(w.x * w.x + w.y * w.y + w.z * w.z))
//
//        if l == 0.0 {
//            // two points together.
//            let sphere = SCNSphere(radius: radius)
//            sphere.firstMaterial?.diffuse.contents = color
//            self.geometry = sphere
//            self.position = startPoint
//            return
//        }
        
        if let selfCylinder = self.geometry as? SCNCylinder {
            selfCylinder.height = l
        }
        
        //original vector of cylinder above 0,0,0
        let ov = SCNVector3(0, l/2.0,0)
        //target vector, in new coordination
        let nv = SCNVector3((endPoint.x - startPoint.x)/2.0, (endPoint.y - startPoint.y)/2.0,
                            (endPoint.z-startPoint.z)/2.0)
        
        // axis between two vector
        let av = SCNVector3( (ov.x + nv.x)/2.0, (ov.y+nv.y)/2.0, (ov.z+nv.z)/2.0)
        
        //normalized axis vector
        let av_normalized = av.normalized
        let q0 = Float(0.0) //cos(angel/2), angle is always 180 or M_PI
        let q1 = Float(av_normalized.x) // x' * sin(angle/2)
        let q2 = Float(av_normalized.y) // y' * sin(angle/2)
        let q3 = Float(av_normalized.z) // z' * sin(angle/2)
        
        let r_m11 = q0 * q0 + q1 * q1 - q2 * q2 - q3 * q3
        let r_m12 = 2 * q1 * q2 + 2 * q0 * q3
        let r_m13 = 2 * q1 * q3 - 2 * q0 * q2
        let r_m21 = 2 * q1 * q2 - 2 * q0 * q3
        let r_m22 = q0 * q0 - q1 * q1 + q2 * q2 - q3 * q3
        let r_m23 = 2 * q2 * q3 + 2 * q0 * q1
        let r_m31 = 2 * q1 * q3 + 2 * q0 * q2
        let r_m32 = 2 * q2 * q3 - 2 * q0 * q1
        let r_m33 = q0 * q0 - q1 * q1 - q2 * q2 + q3 * q3
        
        self.transform.m11 = r_m11
        self.transform.m12 = r_m12
        self.transform.m13 = r_m13
        self.transform.m14 = 0.0
        
        self.transform.m21 = r_m21
        self.transform.m22 = r_m22
        self.transform.m23 = r_m23
        self.transform.m24 = 0.0
        
        self.transform.m31 = r_m31
        self.transform.m32 = r_m32
        self.transform.m33 = r_m33
        self.transform.m34 = 0.0
        
        self.transform.m41 = (startPoint.x + endPoint.x) / 2.0
        self.transform.m42 = (startPoint.y + endPoint.y) / 2.0
        self.transform.m43 = (startPoint.z + endPoint.z) / 2.0
        self.transform.m44 = 1.0
    }
    
    // I assume that the direction of a Light Fragment will never change
//    private func recalculateLength() {
//
//        let w = SCNVector3(x: endPoint.x-startPoint.x,
//                           y: endPoint.y-startPoint.y,
//                           z: endPoint.z-startPoint.z)
//
//        let l = CGFloat(sqrt(w.x * w.x + w.y * w.y + w.z * w.z))
//
//        if let selfCylinder = self.geometry as? SCNCylinder {
//            selfCylinder.height = l
//        }
//
//        //        if l == 0.0 {
//        //            // two points together.
//        //            let sphere = SCNSphere(radius: radius)
//        //            sphere.firstMaterial?.diffuse.contents = color
//        //            self.geometry = sphere
//        //            self.position = startPoint
//        //            return
//        //        }
//
//        // recalc start and end point
//        self.transform.m41 = (startPoint.x + endPoint.x) / 2.0
//        self.transform.m42 = (startPoint.y + endPoint.y) / 2.0
//        self.transform.m43 = (startPoint.z + endPoint.z) / 2.0
//        self.transform.m44 = 1.0
//    }
}
