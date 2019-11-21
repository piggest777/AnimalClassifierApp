//
//  RoundedVisualEffect.swift
//  AnimalClassifierApp
//
//  Created by Denis Rakitin on 2019-10-18.
//  Copyright © 2019 Denis Rakitin. All rights reserved.
//

import UIKit

class RoundedVisualEffect: UIVisualEffectView {

    override func awakeFromNib() {
        self.layer.cornerRadius = 10
        
        self.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMinYCorner]
        self.clipsToBounds = true
        
    }
}
