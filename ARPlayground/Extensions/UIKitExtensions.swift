//
//  UIKitExtensions.swift
//  ARPlayground
//
//  Created by Justin Lycklama on 2019-01-07.
//  Copyright © 2019 Justin Lycklama. All rights reserved.
//

import UIKit

public extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

public extension UIView {
    
    func restrictToSize(_ size: CGSize) {
        self.restrictToSize(size, priority: UILayoutPriority.required)
    }
    
    func restrictToSize(_ size: CGSize, priority: UILayoutPriority) {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let widthConstraint: NSLayoutConstraint, heightConstraint: NSLayoutConstraint
        widthConstraint = NSLayoutConstraint(item: self,
                                             attribute: .width,
                                             relatedBy: .equal,
                                             toItem: nil,
                                             attribute: .notAnAttribute,
                                             multiplier: 1,
                                             constant: size.width)
        
        heightConstraint = NSLayoutConstraint(item: self,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1,
                                              constant: size.height)
        
        widthConstraint.priority = priority
        heightConstraint.priority = priority
        
        NSLayoutConstraint.activate([widthConstraint, heightConstraint])
    }
    
    func constrainSubviewToBounds(_ subview: UIView, withInset inset: UIEdgeInsets = UIEdgeInsets.zero) {
        // subview must be a subview of our cell to be constrained
        if self.subviews.contains(subview) == false {
            return
        }
        
        subview.translatesAutoresizingMaskIntoConstraints = false
        var clingConstraints = [NSLayoutConstraint]()
        
        clingConstraints += [NSLayoutConstraint.init(item: subview, attribute: .trailing, relatedBy:.equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -inset.right)]
        clingConstraints += [NSLayoutConstraint.init(item: subview, attribute: .bottom, relatedBy:.equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -inset.bottom)]
        clingConstraints += [NSLayoutConstraint.init(item: subview, attribute: .top, relatedBy:.equal, toItem: self, attribute: .top, multiplier: 1, constant: inset.top)]
        clingConstraints += [NSLayoutConstraint.init(item: subview, attribute: .leading, relatedBy:.equal, toItem: self, attribute: .leading, multiplier: 1, constant: inset.left)]
        
        NSLayoutConstraint.activate(clingConstraints)
    }
    
    @discardableResult
    func addBorder(edges: UIRectEdge, color: UIColor = UIColor.gray, thickness: CGFloat = 1.0) -> [UIView] {
        
        var borders = [UIView]()
        
        func border() -> UIView {
            let border = UIView(frame: CGRect.zero)
            border.backgroundColor = color
            border.translatesAutoresizingMaskIntoConstraints = false
            return border
        }
        
        if edges.contains(.top) || edges.contains(.all) {
            let top = border()
            addSubview(top)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[top(==thickness)]",
                                               options: [],
                                               metrics: ["thickness": thickness],
                                               views: ["top": top]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[top]-(0)-|",
                                               options: [],
                                               metrics: nil,
                                               views: ["top": top]))
            borders.append(top)
        }
        
        if edges.contains(.left) || edges.contains(.all) {
            let left = border()
            addSubview(left)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[left(==thickness)]",
                                               options: [],
                                               metrics: ["thickness": thickness],
                                               views: ["left": left]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[left]-(0)-|",
                                               options: [],
                                               metrics: nil,
                                               views: ["left": left]))
            borders.append(left)
        }
        
        if edges.contains(.right) || edges.contains(.all) {
            let right = border()
            addSubview(right)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:[right(==thickness)]-(0)-|",
                                               options: [],
                                               metrics: ["thickness": thickness],
                                               views: ["right": right]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[right]-(0)-|",
                                               options: [],
                                               metrics: nil,
                                               views: ["right": right]))
            borders.append(right)
        }
        
        if edges.contains(.bottom) || edges.contains(.all) {
            let bottom = border()
            addSubview(bottom)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:[bottom(==thickness)]-(0)-|",
                                               options: [],
                                               metrics: ["thickness": thickness],
                                               views: ["bottom": bottom]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[bottom]-(0)-|",
                                               options: [],
                                               metrics: nil,
                                               views: ["bottom": bottom]))
            borders.append(bottom)
        }
        
        return borders
    }
    
    class func instanceFromNib(_ xibName: String, inBundle bundle:Bundle) -> UIView {
        return UINib(nibName: xibName, bundle: bundle).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
}

