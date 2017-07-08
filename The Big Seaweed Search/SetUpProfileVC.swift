//
//  SetUpProfileVC.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 05/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class SetUpProfileVC: UIViewController,  UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageAdd: FancyImageView!
    @IBOutlet weak var nameField: FancyField!
    @IBOutlet weak var locationField: FancyField!
    
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var imageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageAdd.image = image
            imageSelected = true
        } else {
            print("CHASE: A valid image wasn't selected")
        }
        //once image selected, dismiss picker view
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addImageTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func postBtnTapped(_ sender: Any) {
        guard let name = nameField.text, name != "" else {
            print("CHASE: Caption must be entered")
            return
        }
        guard let location = locationField.text , location != "" else {
            print("CHASE:  Location must be entered")
            return
        }
        guard let img = imageAdd.image, imageSelected == true else {
            print("CHASE: An image must be selected")
            return
        }
        //get and compress img data
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            //creates a string to unique identify items
            let imgUid = NSUUID().uuidString
            
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            DataService.ds.REF_PROFILE_IMAGES.child(imgUid).put(imgData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print("CHASE: Unable to upload image to Firebase Storage")
                } else {
                    print("CHASE: Successfully uploaded image to Firebase Storage")
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    if let url = downloadURL {
                        self.postToFirebase(imgUrl: url)
                    }
                }
            }
        }
        //Pass user through to main menu screen
        performSegue(withIdentifier: "setUpToMain", sender: nil)
    }
    
    func postToFirebase(imgUrl: String) {
        if let userId = FIRAuth.auth()?.currentUser?.uid{
        let profileData: Dictionary<String,AnyObject> = [
            "username": nameField.text! as AnyObject,
            "location": locationField.text! as AnyObject,
            "photoURL": imgUrl as AnyObject
        ]
      DataService.ds.updateFirebaseDBUserProfile(uid: userId, profileData: profileData)
        print("CHASE: User Profile Updated")
        }
    }
    
}
