//
//  SCNVector3+MathUtils.swift
//  ARPlayground
//
//  Created by Justin Lycklama on 2018-12-08.
//  Copyright © 2018 Justin Lycklama. All rights reserved.
//

import SceneKit

/**
 Add two vectors
 
 - parameter left: Addend 1
 - parameter right: Addend 2
 */
func +(left:SCNVector3, right:SCNVector3) -> SCNVector3 {
    
    return SCNVector3(left.x + right.x, left.y + right.y, left.z + right.z)
}

/**
 Subtract two vectors
 
 - parameter left: Minuend
 - parameter right: Subtrahend
 */
func -(left:SCNVector3, right:SCNVector3) -> SCNVector3 {
    
    return left + (right * -1.0)
}

/**
 Add one vector to another
 
 - parameter left: Vector to change
 - parameter right: Vector to add
 */
func +=( left: inout SCNVector3, right:SCNVector3) {
    
    left = SCNVector3(left.x + right.x, left.y + right.y, left.z + right.z)
}

/**
 Subtract one vector to another
 
 - parameter left: Vector to change
 - parameter right: Vector to subtract
 */
func -=( left: inout SCNVector3, right:SCNVector3) {
    
    left = SCNVector3(left.x - right.x, left.y - right.y, left.z - right.z)
}

/**
 Multiply a vector times a constant
 
 - parameter vector: Vector to modify
 - parameter constant: Multiplier
 */
func *(vector:SCNVector3, multiplier:SCNFloat) -> SCNVector3 {
    
    return SCNVector3(vector.x * multiplier, vector.y * multiplier, vector.z * multiplier)
}

/**
 Multiply a vector times a constant and update the vector inline
 
 - parameter vector: Vector to modify
 - parameter constant: Multiplier
 */
func *=( vector: inout SCNVector3, multiplier:SCNFloat) {
    
    vector = vector * multiplier
}

func == (lhs: SCNVector3?, rhs: SCNVector3?) -> Bool {
    return lhs?.x == rhs?.x && lhs?.y == rhs?.y && lhs?.z == rhs?.z
}


extension SCNVector3 {
    
    /// Calculate the magnitude of this vector
    var magnitude:SCNFloat {
        get {
            return sqrt(dotProduct(self))
        }
    }
    
    /// Vector in the same direction as this vector with a magnitude of 1
    var normalized:SCNVector3 {
        get {
            let localMagnitude = magnitude
            let localX = x / localMagnitude
            let localY = y / localMagnitude
            let localZ = z / localMagnitude
            
            return SCNVector3(localX, localY, localZ)
        }
    }
    
    /**
     Calculate the dot product of two vectors
     
     - parameter vectorB: Other vector in the calculation
     */
    func dotProduct(_ vectorB:SCNVector3) -> SCNFloat {
        
        return (x * vectorB.x) + (y * vectorB.y) + (z * vectorB.z)
    }
    
    /**
     Calculate the dot product of two vectors
     
     - parameter vectorB: Other vector in the calculation
     */
    func crossProduct(_ vectorB:SCNVector3) -> SCNVector3 {
        
        let computedX = (y * vectorB.z) - (z * vectorB.y)
        let computedY = (z * vectorB.x) - (x * vectorB.z)
        let computedZ = (x * vectorB.y) - (y * vectorB.x)
        
        return SCNVector3(computedX, computedY, computedZ)
    }
    
    /**
     Calculate the angle between two vectors
     
     - parameter vectorB: Other vector in the calculation
     */
    func angleBetweenVectors(_ vectorB:SCNVector3) -> SCNFloat {
        
        //cos(angle) = (A.B)/(|A||B|)
        let cosineAngle = (dotProduct(vectorB) / (magnitude * vectorB.magnitude))
        return SCNFloat(acos(cosineAngle))
    }
    
    func description() -> String {
        return "x: " + String(x) + ", y: " + String(y) + ", z: " + String(z)
    }
}
