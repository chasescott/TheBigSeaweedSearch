//
//  ViewProfileVC.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 08/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class ViewProfileVC: UIViewController {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var profileUsername: UILabel!
    @IBOutlet weak var profileLocation: UILabel!
    
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyFirebaseUserInfo()
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    func applyFirebaseUserInfo(img: UIImage? = nil) {
        let uid = FIRAuth.auth()?.currentUser?.uid
        DataService.ds.REF_USERS.child(uid!).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
        //DataService.ds.REF_USERS.child(uid!).child("Profile").observe(.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let usernam = value?["username"] as? String ?? ""
            let locat = value?["location"] as? String ?? ""
            let photoURL = value?["photoURL"] as? String ?? ""
            self.profileUsername.text = usernam
            self.profileLocation.text = locat
            
            if img != nil {
                self.profileImg.image = img
            } else {
                let ref = FIRStorage.storage().reference(forURL: photoURL)
                //calculates max image size for most efficient storage capacity
                ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                    if error != nil {
                        print("CHASE: Unable to download image from Firebase storage")
                    } else {
                        print("CHASE: Image downloaded from Firebase storage")
                        if let imgData = data {
                            if let img = UIImage(data: imgData) {
                                self.profileImg.image = img
                                ViewProfileVC.imageCache.setObject(img, forKey: photoURL as NSString)
                            }
                        }
                    }
                })
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        }

    @IBAction func editBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "viewToEdit", sender: nil)
    }
    

}


