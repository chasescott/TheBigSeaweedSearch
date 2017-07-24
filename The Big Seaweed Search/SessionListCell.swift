//
//  SessionListCell.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 14/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class SessionListCell: UITableViewCell {

    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var gradientLbl: UILabel!
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var postsLbl: UILabel!
    
    var session: Session!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configureCell(session: Session, img: UIImage? = nil) {
        self.session = session
        self.picture.image = #imageLiteral(resourceName: "loading")
        self.nameLbl.text = "Session: \(session.sessionName)"
        self.dateLbl.text = "Date: \(session.date)"
        self.typeLbl.text = "Beach Type:\(session.beachType)"
        self.gradientLbl.text = "Gradient: \(session.beachGradient)"
        self.postsLbl.text = "Number of Posts:  \(session.numberOfPosts)"
        
        if img != nil {
            self.picture.image = img
        } else {
            let ref = FIRStorage.storage().reference(forURL: session.imgURL)
            //calculates max image size for most efficient storage capacity
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("CHASE: Unable to download image from Firebase storage")
                } else {
                    print("CHASE: Image downloaded from Firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.picture.image = img
                            SelectASessionListVC.imageCache.setObject(img, forKey: session.imgURL as NSString)
                        }
                    }
                }
            })
        }
    }
    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//    }

}
