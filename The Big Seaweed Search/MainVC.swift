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

class MainVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func infoBtnTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "goToInfo", sender: nil)
    }
    
    @IBOutlet weak var safetyBtnTapped: UIButton!
    
    @IBAction func safetyButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "goToSafety", sender: nil)
    }
    
    
    @IBAction func ProfileBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: "mainToProfileOptions", sender: nil)
        
    }
    
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
