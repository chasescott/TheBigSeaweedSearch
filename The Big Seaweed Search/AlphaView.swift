//
//  alphaView.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 13/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import UIKit

class AlphaView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.shadowColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.6).cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        layer.cornerRadius = 2.0
        layer.opacity = 0.5
        
    }
    
}
