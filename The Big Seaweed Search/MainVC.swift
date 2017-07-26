//
//  MainVC.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 05/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper


///Main screen view controller
class MainVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
    }

    @IBAction func infoBtnTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "goToInfo", sender: nil)
    }
    
    @IBOutlet weak var safetyBtnTapped: UIButton!
    
    @IBAction func safetyButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "goToSafety", sender: nil)
    }
    
    @IBAction func socialBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: "mainToGroupMenu", sender: nil)
    }
    
    @IBAction func ProfileBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: "mainToProfileOptions", sender: nil)
    }
    
    @IBAction func browseDataTapped(_ sender: Any) {
        performSegue(withIdentifier: "mainMenuToBrowseData", sender: nil)
    }
    
    @IBOutlet weak var rankBtn: FancyButton!
    @IBAction func rankBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: "mainToRankingMenu", sender: nil)
    }
    
    
    /// When sign out tapped, sign out from Firebase authentication and remove key from the Keychain Wrapper to prevent logging back in.
    ///
    /// - Parameter sender: User Id info
    @IBAction func signOutTapped(_ sender: Any) {
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("CHASE: ID removed from keychain \(keychainResult)")
        try! FIRAuth.auth()?.signOut()
        performSegue(withIdentifier: "goToSignOut", sender: nil)
    }
    
    @IBOutlet weak var addDataBtnPressed: FancyButton!

    @IBAction func addDataButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "mainToAddData", sender: nil)
    }
    
}
