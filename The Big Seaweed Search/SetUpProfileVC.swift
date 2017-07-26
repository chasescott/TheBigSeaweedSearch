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

///Set up profile view controller - only seen when user is new and signing in for the first time.
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
        userAlertWelcome(alert: "Thank you for joining the Big Seaweed Search.  Your contributions to this project will prove invaluable in our fight to protect the coastal waters of the UK.  \r\n \r\n Just a few points before you start... \r\n \r\n Firstly, please complete the details on this page to allow us to set up a profile for you.  \r\n \r\n Secondly, please read the safety information in the main menu. \r\n \r\n Thirdly, please read the instructions before proceeding to collect data. \r\n \r\n Happy Seaweed Searching!")
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

    /// Image Pickert Controller enables user to select image from library
    ///
    /// - Parameters:
    ///   - picker: picker object
    ///   - info: data stored within the image picker
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
    
    /// Method to run when the Save button is pressed.  Take the image in the picker viewer, create a string to unique identify the image, upload the image to Firebase storage and then run the postToFirebase method.
    ///
    /// - Parameter sender: Data relating to the image.
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
    
    /// Method to post all user data to Firebase.
    ///1. Store user data in dictionary and store data against user node on Firebase.
    /// - Parameter imgUrl: the image URL of the profile picture storage location on Firebase
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
        userAlert(alert: "Thank you, your profile has been set up.  Please proceed to the main menu")
        print("CHASE: User Profile Updated")
        }
    }
    
    ///User alert windows to warn of issue that needs attention before proceeding
    ///
    /// - Parameter alert:  String to represent the problem that requires attention from the user.
    func userAlertDoMore (alert: String) {
        let alertController = UIAlertController(title: "The Big SeaWeed Search", message: alert, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert + 1;
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    ///User alert to welcome the user and alert of the next steps.  This is used in the viewDidLoad() function so is the first object a user will see and interact with.
    ///
    /// - Parameter alert:  String to represent the welcome message.
    func userAlertWelcome (alert: String) {
        let alertController = UIAlertController(title: "Welcome!", message: alert, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Ok, lets proceed!", style: UIAlertActionStyle.cancel, handler: nil))
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert + 1;
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alertController, animated: true, completion: nil)
    }

    ///User alert windows to advise of success and segue to the next screen.
    ///
    /// - Parameter alert: String to represent congratulations that needs to pop up
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
    

