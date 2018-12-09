//
//  Light.swift
//  ARPlayground
//
//  Created by Justin Lycklama on 2018-12-08.
//  Copyright © 2018 Justin Lycklama. All rights reserved.
//

import UIKit
import ARKit

typealias KeyFrameId = String
typealias KeyFrameKey = String

struct LightFragmentKeyFrame: Equatable {
    let id: KeyFrameId
    var position: SCNVector3
    var direction: SCNVector3
    
    init(position: SCNVector3, direction: SCNVector3) {
        self.id = UUID().uuidString
        self.position = position
        self.direction = direction
    }
    
    static func == (lhs: LightFragmentKeyFrame, rhs: LightFragmentKeyFrame) -> Bool {
        return lhs.id == rhs.id
    }
    
    func keyFrameKey(with keyFrame: LightFragmentKeyFrame) -> KeyFrameKey {
        return self.id + keyFrame.id
    }
}

struct LightFragmentContainer {
    let fragment: LightFragment
    let startKeyFrame: LightFragmentKeyFrame
    let endKeyFrame: LightFragmentKeyFrame
}

class Light: SCNNode {

    var keyFrames = [LightFragmentKeyFrame]()
    var fragments = [KeyFrameId : LightFragmentContainer]()
    
    private let speed: SCNFloat = 1
    private let raduis: CGFloat = 0.005
    private let color: UIColor = .red
    
    init(initialPosition: SCNVector3, direction: SCNVector3) {
        super.init()
        
        keyFrames.append(LightFragmentKeyFrame(position: initialPosition, direction: direction))
        
        let movement = direction.normalized * speed
        keyFrames.append(LightFragmentKeyFrame(position: initialPosition + movement, direction: SCNVector3.init()))

        let secondMovement = SCNVector3(0, 1, 0).normalized * speed
        keyFrames.append(LightFragmentKeyFrame(position: initialPosition + movement + secondMovement, direction: secondMovement))

        updateFragments()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Perform movement. Update the virtual positions of the light
    public func updateKeyFrames() {
        
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
