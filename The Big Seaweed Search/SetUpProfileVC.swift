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

class SetUpProfileVC: UIViewController,  UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

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
        nameField.delegate = self
        locationField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameField.resignFirstResponder()
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
    
    @IBAction func addImageTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func postBtnTapped(_ sender: Any) {
        guard let name = nameField.text, name != "" else {
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
        //Pass user through to main menu screen
        //performSegue(withIdentifier: "setUpToMain", sender: nil)
    }
    
    func postToFirebase(imgUrl: String) {
        if let userId = FIRAuth.auth()?.currentUser?.uid{
        let profileData: Dictionary<String,AnyObject> = [
            "username": nameField.text! as AnyObject,
            "location": locationField.text! as AnyObject,
            "photoURL": imgUrl as AnyObject
        ]
      DataService.ds.updateFirebaseDBUserProfile(uid: userId, profileData: profileData)
      DataService.ds.SetUpFirebaseNumberOfPosts(uid: userId)
      DataService.ds.SetUpFirebaseNumberOfSessions(uid: userId)
            let userData: Dictionary<String,AnyObject> = [
                "username": nameField.text! as AnyObject,
                "location": locationField.text! as AnyObject,
                "numberOfPosts": 0 as AnyObject,
                "numberOfSessions": 0 as AnyObject,
                "photoURL": imgUrl as AnyObject
            ]
        DataService.ds.setUpUserOnLeaderboard(uid: userId, userData: userData)
        userAlert(alert: "Thank you.  Your profile has been updated")
        print("CHASE: User Profile Updated")
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
            action in self.performSegue(withIdentifier: "setUpToMain", sender: nil)
        }))
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert + 1;
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    }
    

