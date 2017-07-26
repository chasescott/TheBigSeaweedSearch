//
//  UserDataListCell.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 14/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import UIKit
import Firebase

/// UserDataListCell class for cells in Tableview in ViewOwnDataVC
class UserDataListCell: UITableViewCell {

    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var seaweedLbl: UILabel!
    @IBOutlet weak var latiLbl: UILabel!
    @IBOutlet weak var longiLbl: UILabel!
    
    var userpost: UserPost!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    /// Configure the cell
    ///
    /// - Parameters:
    ///   - userpost: UserPost object
    ///   - img: UIImage for the picture label
    func configureCell(userpost: UserPost, img: UIImage? = nil) {
        self.userpost = userpost
        self.picture.image = #imageLiteral(resourceName: "loading")
        self.seaweedLbl.text = "Seaweed type: \(userpost.seaweedType!)"
        let x = Double(userpost.lati)
        let y = Double(round(10000000*x!)/10000000)
        let w = Double(userpost.longi)
        let z = Double(round(10000000*w!)/10000000)
        self.latiLbl.text = "Latitude: \(y)"
        self.longiLbl.text = "Longitude:\(z)"

        
        if img != nil {
            self.picture.image = img
        } else {
            let ref = FIRStorage.storage().reference(forURL: userpost.photoURL)
            //calculates max image size for most efficient storage capacity
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("CHASE: Unable to download image from Firebase storage")
                } else {
                    print("CHASE: Image downloaded from Firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.picture.image = img
                            ViewOwnDataVC.imageCache.setObject(img, forKey: userpost.photoURL as NSString)
                        }
                    }
                }
            })
        }
    }


}
