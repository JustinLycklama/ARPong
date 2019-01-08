//
//  Extensions.swift
//  ARPlayground
//
//  Created by Justin Lycklama on 2018-12-11.
//  Copyright © 2018 Justin Lycklama. All rights reserved.
//

import Foundation
import SceneKit

extension SCNNode {
    
    /// The local unit Y axis (0, 1, 0) in parent space.
    var parentUp: SCNVector3 {
        
        let transform = self.transform
        return SCNVector3(transform.m21, transform.m22, transform.m23)
    }
    
    /// The local unit X axis (1, 0, 0) in parent space.
    var parentRight: SCNVector3 {
        
        let transform = self.transform
        return SCNVector3(transform.m11, transform.m12, transform.m13)
    }
    
    /// The local unit -Z axis (0, 0, -1) in parent space.
    var parentFront: SCNVector3 {
        
        let transform = self.transform
        return SCNVector3(-transform.m31, -transform.m32, -transform.m33)
    }
}

extension GLKQuaternion {
    
    init(vector: GLKVector3, scalar: Float) {
        
        let glkVector = GLKVector3Make(vector.x, vector.y, vector.z)
        
        self = GLKQuaternionMakeWithVector3(glkVector, scalar)
    }
    
    init(angle: Float, axis: GLKVector3) {
        
        self = GLKQuaternionMakeWithAngleAndAxis(angle, axis.x, axis.y, axis.z)
    }
    
    func normalized() -> GLKQuaternion {
        
        return GLKQuaternionNormalize(self)
    }
    
    static var identity: GLKQuaternion {
        
        return GLKQuaternionIdentity
    }
}

func * (left: GLKQuaternion, right: GLKQuaternion) -> GLKQuaternion {
    
    return GLKQuaternionMultiply(left, right)
}

extension SCNQuaternion {
    
    init(_ quaternion: GLKQuaternion) {
        
        self = SCNVector4(quaternion.x, quaternion.y, quaternion.z, quaternion.w)
    }
}

extension GLKQuaternion {
    
    init(_ quaternion: SCNQuaternion) {
        
        self = GLKQuaternionMake(quaternion.x, quaternion.y, quaternion.z, quaternion.w)
    }
}

extension GLKVector3 {
    
    init(_ vector: SCNVector3) {
        self = SCNVector3ToGLKVector3(vector)
    }
}
