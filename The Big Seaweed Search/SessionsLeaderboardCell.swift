//
//  SessionsLeaderboardCell.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 19/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import UIKit
import Firebase

/// SessionsLeaderboardCell class for cells in Tableview in SessionsLeaderboardVC
class SessionsLeaderboardCell: UITableViewCell {
    
    @IBOutlet weak var picture: FancyImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var rankLbl: UILabel!
    @IBOutlet weak var postsLbl: UILabel!
    
    var postranking: PostRanking!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /// Configure the cell
    ///
    /// - Parameters:
    ///   - postranking: PostRanking object
    ///   - img: UIImage for the picture label
    func configureCell(postranking: PostRanking, img: UIImage? = nil) {
        self.postranking = postranking
        self.usernameLbl.text = "\(postranking.username)"
        self.rankLbl.text = "\(postranking.rank)"
        self.postsLbl.text = "\(postranking.numberOfPosts)"
        self.picture.image = #imageLiteral(resourceName: "loading")
        
        
        if img != nil {
            self.picture.image = img
        } else {
            let ref = FIRStorage.storage().reference(forURL: postranking.userImgURL)
            //calculates max image size for most efficient storage capacity
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("CHASE: Unable to download image from Firebase storage")
                } else {
                    print("CHASE: Image downloaded from Firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.picture.image = img
                            SessionsLeaderboardVC.imageCache.setObject(img, forKey: postranking.userImgURL as NSString)
                        }
                    }
                }
            })
        }
    }
    
    
}
