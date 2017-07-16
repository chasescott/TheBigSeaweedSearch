//
//  DataPostCell.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 16/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import UIKit
import Firebase

class DataPostCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var likesImg: UIImageView!
    @IBOutlet weak var postImg: FancyImageView!
    @IBOutlet weak var viewInfo: UILabel!
    @IBOutlet weak var captionLbl: UILabel!
    @IBOutlet weak var likesLbl: UILabel!
    
    var datapost: DataPost!
    var likesRef: FIRDatabaseReference!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likesImg.addGestureRecognizer(tap)
        likesImg.isUserInteractionEnabled = true
    }
    
    func configureCell(datapost:DataPost, img: UIImage? = nil) {
        self.datapost = datapost
        likesRef = DataService.ds.REF_USER_CURRENT.child("likes").child(datapost.postKey)
        self.captionLbl.text = datapost.seaweedType
        self.likesLbl.text = "Number of Likes: \(datapost.likes)"
        self.userNameLbl.text = datapost.username
        
        if img != nil {
            self.postImg.image = img
            self.profileImg.image = img
        } else {
            let ref1 = FIRStorage.storage().reference(forURL: datapost.photoURL)
            //calculates max image size for most efficient storage capacity
            ref1.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("CHASE: Unable to download image from Firebase storage")
                } else {
                    print("CHASE: Image downloaded from Firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.postImg.image = img
                            ViewAllDataVC.imageCache.setObject(img, forKey: datapost.photoURL as NSString)
                        }
                    }
                }
            })
            let ref2 = FIRStorage.storage().reference(forURL: datapost.userimgURL)
            ref2.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("CHASE: Unable to download image from Firebase storage")
                } else {
                    print("CHASE: Image downloaded from Firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.profileImg.image = img
                            ViewAllDataVC.imageCache.setObject(img, forKey: datapost.userimgURL as NSString)
                        }
                    }
                }
            })
        }
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likesImg.image = UIImage(named: "empty-heart")
            } else {
                self.likesImg.image = UIImage(named: "filled-heart")
            }
            
        })
        
    }
    
    func likeTapped(sender: UITapGestureRecognizer){
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likesImg.image = UIImage(named: "filled-heart")
                self.datapost.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
            } else {
                self.likesImg.image = UIImage(named: "empty-heart")
                self.datapost.adjustLikes(addLike: false)
                self.likesRef.removeValue()
            }
            
        })
    }
}
