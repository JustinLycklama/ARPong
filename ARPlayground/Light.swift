//
//  Light.swift
//  ARPlayground
//
//  Created by Justin Lycklama on 2018-12-08.
//  Copyright © 2018 Justin Lycklama. All rights reserved.
//

import UIKit
import ARKit

struct KeyFrameId {
    let value: String
    
    static func == (lhs: KeyFrameId, rhs: KeyFrameId) -> Bool {
        return lhs.value == rhs.value
    }
    
    static func + (lhs: KeyFrameId, rhs: KeyFrameId) -> String {
        return lhs.value + rhs.value
    }
}

struct KeyFrameKey: Equatable, Hashable {
    let value: String
    
    var hashValue: Int { get {return value.hashValue} }
    
    static func == (lhs: KeyFrameKey, rhs: KeyFrameKey) -> Bool {
        return lhs.value == rhs.value
    }
}

// This is a class, so when we update keyframes position, the reference is updated in our LightFragmentContainer
class LightFragmentKeyFrame: Equatable {
    let id: KeyFrameId
    var position: SCNVector3
    var direction: SCNVector3?
    
    init(position: SCNVector3, direction: SCNVector3?) {
        self.id = KeyFrameId(value: UUID().uuidString)
        self.position = position
        self.direction = direction
    }
    
    func setPosition(position: SCNVector3) {
        self.position = position
    }
    
    static func == (lhs: LightFragmentKeyFrame, rhs: LightFragmentKeyFrame) -> Bool {
        return lhs.id == rhs.id
    }
    
    func keyFrameKey(with keyFrame: LightFragmentKeyFrame) -> KeyFrameKey {
        return KeyFrameKey(value: self.id + keyFrame.id)
    }
}

public struct LightFragmentContainer {
    let fragment: LightFragment
    let startKeyFrame: LightFragmentKeyFrame
    let endKeyFrame: LightFragmentKeyFrame
}

class Light: SCNNode {

    var keyFrames = [LightFragmentKeyFrame]()
    
    // The fragment related to the
    var fragments = [KeyFrameKey : LightFragmentContainer]()
    
    private let speed: SCNFloat = 0.05
    private let raduis: CGFloat = 0.005
    private let color: UIColor = .red
    
    init(initialPosition: SCNVector3, direction: SCNVector3) {
        super.init()
        
        let movement = direction.normalized * speed
        keyFrames.append(LightFragmentKeyFrame(position: initialPosition + movement, direction: nil))
        
        keyFrames.append(LightFragmentKeyFrame(position: initialPosition, direction: direction))
        
        

//        let secondMovement = SCNVector3(0, 1, 0).normalized * speed
//        keyFrames.append(LightFragmentKeyFrame(position: initialPosition + movement + secondMovement, direction: secondMovement))

        updateFragments()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func getLeadingFragment() -> LightFragmentContainer? {
        if keyFrames.count >= 2 {
            let leadingKeyFrame = keyFrames[keyFrames.count - 1]
            let previousKeyFrame = keyFrames[keyFrames.count - 2]
            
            let keyFrameKey = leadingKeyFrame.keyFrameKey(with: previousKeyFrame)
            
            return fragments[keyFrameKey]
        }
        
        return nil
    }
    
    // Perform movement. Update the virtual positions of the light
    public func updateKeyFrames(distance: Float) {
        for i in 0..<keyFrames.count {
            let keyFrame = keyFrames[i]

            guard let direction = keyFrame.direction else {
                continue
            }
            
            keyFrames[i].setPosition(position: keyFrame.position + (direction.normalized * distance))
        }
    }
    
    private let err: SCNFloat = 0.0001 // Avoid colliding again with this error offset
    
    public func createNewFragment(cutPosition: SCNVector3, direction: SCNVector3) {
     
        // Our last keyframe should stop moving at this position
        if keyFrames.count > 0,
            let lastDirection = keyFrames[keyFrames.count - 1].direction {
            keyFrames[keyFrames.count - 1].position = cutPosition + (lastDirection * -err)
            keyFrames[keyFrames.count - 1].direction = nil
        }
        
        keyFrames.append(LightFragmentKeyFrame(position: cutPosition + (direction * err), direction: direction))
        
        NSLog("Start")
        for keyFrame in keyFrames {
            NSLog(keyFrame.direction?.description() ?? "nil")
        }
        NSLog("End")
    }
    
    // Update the Node objects to reflect our virtual positions
    public func updateFragments() {
        
        var preiviousOptional: LightFragmentKeyFrame? = nil
        for keyFrame in keyFrames {
            guard let lastKeyFrame = preiviousOptional else {
                preiviousOptional = keyFrame
                continue
            }
            
            // keyFrameKey is the combination of the starting point and ending point ids
            let keyFrameKey = keyFrame.keyFrameKey(with: lastKeyFrame)
            let fragmentContainer: LightFragmentContainer! = fragments[keyFrameKey]
            
            // We do not yet have a light fragment for these key frames.
            // -> A new key frame was added. We need to create a new fragment to represent this key frame
            if fragmentContainer == nil {
                let newFragment = LightFragment(startPoint: lastKeyFrame.position,
                                                endPoint: keyFrame.position,
                                                radius: raduis,
                                                color: color)
                
                self.addChildNode(newFragment)
                
                let container = LightFragmentContainer(fragment: newFragment,
                                                       startKeyFrame: lastKeyFrame,
                                                       endKeyFrame: keyFrame)
                
                fragments[keyFrameKey] = container
            }
            // We already have a SCNNode that represents this next keyframe
            // Update its position to reflect our virtual position
            else {
                fragmentContainer.fragment.update(startPoint: lastKeyFrame.position, endPoint: keyFrame.position)
            }

            preiviousOptional = keyFrame
        }
        
//        var indicies = [Int]()
//
//        for i in 0..<fragments.count {
//            indicies.append(i)
//        }
//
//
//        let verticies = fragments.compactMap { (fragment: LightFragment) -> SCNVector3 in
//            return fragment.position
//        }
//        let vertexSource = SCNGeometrySource(vertices: verticies)
//
////        let data = NSData(bytes: indicies, length: MemoryLayout.size(ofValue: indicies))
//
////        let element = SCNGeometryElement(data: data as Data, primitiveType: SCNGeometryPrimitiveType.line, primitiveCount: 1, bytesPerIndex: MemoryLayout.size(ofValue: Int.self))
//        let element = SCNGeometryElement(indices: indicies, primitiveType: .line)
//
//
//        let line = SCNGeometry(sources: [vertexSource], elements: [element])
//
//        line.firstMaterial?.diffuse.contents = UIColor.red
//
//
////                    let boxGeometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.1)
////
////self.geometry = boxGeometry
//
//
//        self.geometry = line
//        glLineWidth(20)
        
        
//        let path = UIBezierPath()
//        if let start = fragments.first {
//            path.move(to: <#T##CGPoint#>)
//        }
//
//
//
//        SCNShape.init(path: path, extrusionDepth: 0.25)
    
        
        
        


    }
}
