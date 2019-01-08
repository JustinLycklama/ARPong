//
//  LSInterfaceController.swift
//  ARPlayground
//
//  Created by Justin Lycklama on 2019-01-07.
//  Copyright © 2019 Justin Lycklama. All rights reserved.
//

import UIKit

class LSInterfaceController: UIViewController {

    public var delegate: LSSceneDelegate?
    
    private let resetButton = UIButton()
    private let placeArenaButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        resetButton.setTitle("Reset", for: .normal)
        resetButton.setTitleColor(.black, for: .normal)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.addBorder(edges: .all)
        
        resetButton.addTarget(self, action: #selector(LSInterfaceController.resetPressed(_:)), for: .touchUpInside)
        
        self.view.addSubview(resetButton)
        
        placeArenaButton.setTitle("Place Arena", for: .normal)
        placeArenaButton.setTitleColor(.black, for: .normal)
        placeArenaButton.translatesAutoresizingMaskIntoConstraints = false
        placeArenaButton.addBorder(edges: .all)
        
        placeArenaButton.addTarget(self, action: #selector(LSInterfaceController.placeArenaPressed(_:)), for: .touchUpInside)
        
        self.view.addSubview(placeArenaButton)
        
        let views = ["reset" : resetButton,
                     "place" : placeArenaButton]
        
        let resetButtonHorizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:[reset]-(16)-|", options: [], metrics: [:], views: views)
        let resetButtonVertical = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(16)-[reset]", options: [], metrics: [:], views: views)
        
        NSLayoutConstraint.activate(resetButtonHorizontal)
        NSLayoutConstraint.activate(resetButtonVertical)
        
        let placeButtonHorizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(16)-[place]-(16)-|", options: [], metrics: [:], views: views)
        let placeButtonVertical = NSLayoutConstraint.constraints(withVisualFormat: "V:[place]-(32)-|", options: [], metrics: [:], views: views)
        
        NSLayoutConstraint.activate(placeButtonHorizontal)
        NSLayoutConstraint.activate(placeButtonVertical)
        
        self.view.layer.borderColor = UIColor.red.cgColor
        self.view.layer.borderWidth = 2
    }

    @objc
    fileprivate func resetPressed(_ sender: Any) {
        delegate?.requestResetExperience()
    }
    
    @objc
    fileprivate func placeArenaPressed(_ sender: Any) {
        delegate?.requestCreateArena()
    }
    
    // MARK: - Public
    public func enablePlaceArena(bool: Bool) {
        placeArenaButton.isEnabled = bool
    }
}
