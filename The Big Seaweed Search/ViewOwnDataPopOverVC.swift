//
//  ViewOwnDataPopOverVC.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 15/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase

class ViewOwnDataPopOverVC: UIViewController {

    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var latLbl: UILabel!
    @IBOutlet weak var longLbl: UILabel!
    
    private var _currentUserPost: UserPost!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var img: UIImage? = nil
    
    //GPS location storage variables
    let locationManager = CLLocationManager()
    var beachLocation = CLLocation()
    
    var currentUserPost: UserPost {
        get {
            return _currentUserPost
        } set {
            _currentUserPost = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
    typeLbl.text = "Seaweed Type: \(currentUserPost.seaweedType!)"
    latLbl.text = "Latitude: \(currentUserPost.lati!)"
        longLbl.text = "Longitude: \(currentUserPost.longi!)"
        
        if img != nil {
            self.picture.image = img
        } else {
            let ref = FIRStorage.storage().reference(forURL: currentUserPost.photoURL)
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("CHASE: Unable to download image from Firebase storage")
                } else {
                    print("CHASE: Image downloaded from Firebase Storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData)
                        {
                            self.picture.image = img
                            ViewOwnDataPopOverVC.imageCache.setObject(img, forKey: self.currentUserPost.photoURL as NSString)
                        }
                    }
                }
            })
        }
    }

    @IBAction func cancelBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
