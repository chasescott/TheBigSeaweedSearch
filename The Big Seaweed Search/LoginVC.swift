//
//  ViewController.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 05/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Firebase
import FBSDKLoginKit
import SwiftKeychainWrapper

///Login View Controller Class for the first class to appear, the login screen
class LoginVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var pwdField: FancyField!
    @IBOutlet weak var signInTapBtn: FancyButton!
    
    //Constant Firebase reference to plain profile image used to set up profile - just in case user opts not to upload own photo
    let plainProfileImg = "https://firebasestorage.googleapis.com/v0/b/seaweed-b955e.appspot.com/o/profile-pics%2Fuser1.jpg?alt=media&token=7abad0cb-2597-4ba0-ae2a-eca299b29f92"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        emailField.delegate = self
        pwdField.delegate = self
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailField.resignFirstResponder()
        pwdField.resignFirstResponder()
        return false
    }

    
    override func viewDidAppear(_ animated: Bool) {
        //checks if key exists in keychain, then do foo
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            print("CHASE: ID found in keychain")
            performSegue(withIdentifier: "goToMain", sender: nil)
        }
    }
    
    /// Facebook log in method using Firebase and Facebook authorisation tools.
    ///
    /// - Parameter sender: Facebook credentials
    @IBAction func fbBtnTapped(_ sender: Any) {
        
        let facebookLogin  = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("CHASE: Unable to authenticate with Facebook - \(String(describing: error))")
            } else if result?.isCancelled == true {
                print("CHASE: User cancelled Facebook authentication")
            } else {
                print("CHASE:  Successfully authenticated with Facebook")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
        }
    }

    ///  Code required to authorise user with Firebase using email and address method only
    ///
    /// - Parameter credential: Credential user information
    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("CHASE:  Unable to authenticate with Firebase - \(String(describing: error))")
            } else {
                print("CHASE:  Successfully authenticated with Firebase")
                if let user = user {
                    let userData = ["provider": credential.provider]
                    self.completeSignIn(id: user.uid, userData: userData)
                    //get & insert profile data
                    let profileData = ["username:": user.email as AnyObject,
                        "location": "To be confirmed" as AnyObject,
                        "photoURL": self.plainProfileImg as AnyObject
                    ]
                    self.createUserProfile(id: user.uid, profileData: profileData)
                    //perform segue
                    self.performSegue(withIdentifier: "goToSetUp", sender: nil)
                }
            }
        })
    }
    

    /// Sign in button tapped.  Check if email/password not nil and run Firebase authentication code.
    /// If user does not exist, create new user profile and authentication using inputted password/email.
    ///
    /// - Parameter sender: User credential data
    @IBAction func signInTapped(_ sender: Any) {
        if let email = emailField.text, let pwd = pwdField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if error == nil {
                    print("CHASE: Email user Authenticated with Firebase")
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        self.completeSignIn(id: user.uid, userData: userData)
                        //get & insert profile data
                        let profileData = ["username:": user.email as AnyObject,
                                           "location": "To be confirmed" as AnyObject,
                                           "photoURL": self.plainProfileImg as AnyObject
                        ]
                        self.createUserProfile(id: user.uid, profileData: profileData)
                        //perform segue
                        self.performSegue(withIdentifier: "goToMain", sender: nil)
                    }
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
                        if error != nil {
                            print("CHASE: Unable to authenticate with Firebase using email")
                        } else {
                            print("CHASE: Successfully authenticated with Firebase")
                            if let user = user {
                                let userData = ["provider": user.providerID]
                                self.completeSignIn(id: user.uid, userData: userData)
                                //get & insert profile data
                                let profileData = ["username": user.email as AnyObject,
                                                   "location": "To be confirmed" as AnyObject,
                                                   "photoURL": self.plainProfileImg as AnyObject
                                ]
                                self.createUserProfile(id: user.uid, profileData: profileData)
                                //perform segue
                                self.performSegue(withIdentifier: "goToSetUp", sender: nil)
                            }
                        }
                    })
                }
            })
        }
    }
    
    /// Stores the username and password in the devices Keychain so that the user doesn't need to log in each time the app loads.
    ///
    /// - Parameters:
    ///   - id: the user id
    ///   - userData: user id and password stored in String Dictionary
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("CHASE: Data saved to keychain \(keychainResult)")
    }

    /// Automatically create user profile if new user
    ///
    /// - Parameters:
    ///   - id: user Id
    ///   - profileData: Dictionary of profileData to be uploaded to Firebase
    func createUserProfile(id: String, profileData: Dictionary<String, AnyObject>) {
        DataService.ds.createFirebaseDBUserProfile(uid: id, profileData: profileData)
        print("CHASE: User Profile Created")
    }
}

