//
//  EditProfileVC.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 05/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class EditProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var userField: FancyField!
    @IBOutlet weak var locationField: FancyField!
    @IBOutlet weak var imageAdd: UIImageView!
    
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var imageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        applyFirebaseUserInfo()
        userField.delegate = self
        locationField.delegate = self
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        userField.resignFirstResponder()
        locationField.resignFirstResponder()
        return false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageAdd.image = image
            imageSelected = true
        } else {
            userAlertDoMore(alert: "A valid image was not selected.  Please try again")
            print("CHASE: A valid image wasn't selected")
        }
        //once image selected, dismiss picker view
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func photoTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func editNameTapped(_ sender: Any) {
        userField.becomeFirstResponder()
        userField.isUserInteractionEnabled = true
        userField.text = ""
    }
    
    @IBAction func editLocationTapped(_ sender: Any) {
        locationField.becomeFirstResponder()
        locationField.isUserInteractionEnabled = true
        locationField.text = ""
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        guard let name = userField.text, name != "" else {
            userAlertDoMore(alert: "Please enter a username")
            print("CHASE: Name must be entered")
            return
        }
        guard let location = locationField.text , location != "" else {
            userAlertDoMore(alert: "Please enter your location")
            print("CHASE:  Location must be entered")
            return
        }
        guard let img = imageAdd.image, imageSelected == true else {
            userAlertDoMore(alert: "Please select a profile image")
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
                    self.userAlertDoMore(alert: "Unable to upload image.  Please try again")
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
    }
    
    func postToFirebase(imgUrl: String) {
        if let userId = FIRAuth.auth()?.currentUser?.uid{
            let profileData: Dictionary<String,AnyObject> = [
                "username": userField.text! as AnyObject,
                "location": locationField.text! as AnyObject,
                "photoURL": imgUrl as AnyObject
            ]
            DataService.ds.updateFirebaseDBUserProfile(uid: userId, profileData: profileData)
            userAlert(alert: "Thank you.  Your profile has been updated")
            print("CHASE: User Profile Updated")
        }
    }

    func applyFirebaseUserInfo(img: UIImage? = nil) {
        let uid = FIRAuth.auth()?.currentUser?.uid
        DataService.ds.REF_USERS.child(uid!).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            let usernam = value?["username"] as? String ?? ""
            let locat = value?["location"] as? String ?? ""
            let photoURL = value?["photoURL"] as? String ?? ""
            self.userField.text = usernam
            self.locationField.text = locat
            
            if img != nil {
                self.imageAdd.image = img
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
                                self.imageAdd.image = img
                                EditProfileVC.imageCache.setObject(img, forKey: photoURL as NSString)
                            }
                        }
                    }
                })
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
  
    //User alert windows to warn of issue that needs attention before proceeding
    func userAlertDoMore (alert: String) {
        let alertController = UIAlertController(title: "The Big SeaWeed Search", message: alert, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert + 1;
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    //User alert to advise of success and perform segue to next screen
    func userAlert (alert: String) {
        let alertController = UIAlertController(title: "The Big SeaWeed Search", message: alert, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: {
            action in self.performSegue(withIdentifier: "editToOptions", sender: nil)
        }))
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert + 1;
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
}
