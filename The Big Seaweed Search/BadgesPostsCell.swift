//
//  BadgesPostsCell.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 19/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import UIKit

class BadgesPostsCell: UICollectionViewCell {
    
    var postBadge: UIImage!
    
    @IBOutlet weak var picture: FancyImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(img: UIImage? = nil)
    {
        if img != nil {
        self.picture.image = img
    }
    }
    
}
