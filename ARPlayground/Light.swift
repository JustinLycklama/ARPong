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
    
    /* When creating a KeyFrameKey use the farther ahead keyFrame first */
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

    public static let standardErrorOffset: SCNFloat = 0.001
    
    // First KeyFrame is the end of the line. Last keyframe is the head, with the direction vector
    var keyFrames = [LightFragmentKeyFrame]()
    
    // The fragment related to a pair of KeyFrames
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
    
    let maxDistance: SCNFloat = 0.1
    let minDistanceDeleteThreshold: SCNFloat = 0.001
    
    // Perform movement. Update the virtual positions of the light
    public func updateKeyFrames(movement: Float) {
        
        var incrementalDistance: SCNFloat = 0
        
        for i in (0..<keyFrames.count).reversed() {
            let keyFrame = keyFrames[i]

            if let direction = keyFrame.direction {
                keyFrames[i].setPosition(position: keyFrame.position + (direction.normalized * movement))
            }
            
            // If there is a keyframe after this, check distance to that
            if keyFrames.count > i + 1 {
                let nextKeyFrame = keyFrames[i+1]
                let thisDistance = (keyFrame.position - nextKeyFrame.position).magnitude
                
                if incrementalDistance + thisDistance > maxDistance {
                    
                    NSLog("This fragment hits our max total. Reduce!")
                    NSLog("Inc Distance " + String(incrementalDistance))
                    NSLog("This Distance " + String(thisDistance))

                    // Move this end point up to be our total distance, and set its direction vector
                    let remainingDistance = maxDistance - incrementalDistance
                    
                    // E.g. if we should only be going 1 more, but we have a length of 2, we need 1/2 of our current length
                    let percentageRequired = remainingDistance / thisDistance
                    
                    let direction = nextKeyFrame.position - keyFrame.position
                    
                    // Update the position to be JUST under the maxLength. This way the next iteration should not trigger this set of commands again
                    keyFrames[i].direction = direction.normalized
                    keyFrames[i].setPosition(position: keyFrame.position + (direction * (1 - percentageRequired)) + (direction.normalized * movement)) // + (direction * (1 - percentageRequired))
                    
                    // This fragment already covers the max distance. Remove any leftover keyframes after this one
                    removeFragments(lastKeyFramePosition: i)
                    break
                }
                
                incrementalDistance += thisDistance
            }
        }
    }
    
    private func removeFragments(lastKeyFramePosition position: Int) {
        guard position < keyFrames.count else {
            return
        }
        
        if position > 0 {
            NSLog("We are actually removing elements. " + String(position))
        }
        
        for i in 0..<position {
            let toRemoveFrame = keyFrames[i]
            guard i+1 < keyFrames.count else {
                    continue
            }
            
            let nextKeyFrame = keyFrames[i + 1]
            let keyFrameKey = nextKeyFrame.keyFrameKey(with: toRemoveFrame)
            let fragmentContainer: LightFragmentContainer? = fragments[keyFrameKey]

            fragmentContainer?.fragment.removeFromParentNode()
            fragments[keyFrameKey] = nil
        }
        
        keyFrames.removeFirst(position)
    }
    
    public func createNewFragment(cutPosition: SCNVector3, direction: SCNVector3) {
     
        // Our last keyframe should stop moving at this position
        if keyFrames.count > 0,
            let lastDirection = keyFrames[keyFrames.count - 1].direction {
            keyFrames[keyFrames.count - 1].position = cutPosition + (lastDirection * -Light.standardErrorOffset)
            keyFrames[keyFrames.count - 1].direction = nil
        }
        
        keyFrames.append(LightFragmentKeyFrame(position: cutPosition, direction: direction))
        
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
    }
}
