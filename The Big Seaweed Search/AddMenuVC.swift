//
//  AddMenuVC.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 09/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import UIKit
import Firebase

//AddMenuVC View Controller Class for 'Add Data Menu'
class AddMenuVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if let uid = FIRAuth.auth()?.currentUser?.uid {
        DataService.ds.REF_USERS.child(uid).observe(.value, with: { snapshot in
        let sessionsValue = snapshot.value as? Dictionary<String,AnyObject>
        let numberOfSessions = sessionsValue?["numberOfSessions"] as! Int
        let numberOfPosts = sessionsValue?["numberOfPosts"] as! Int
            if numberOfSessions == 0 && numberOfPosts == 0  {
                self.continuePrevSession.isEnabled = false
                self.continuePrevSession.isHidden = true
            } else {
                self.continuePrevSession.isEnabled = true
                self.continuePrevSession.isHidden = false
            }
        })
    }
    }

    @IBOutlet weak var continuePrevSession: FancyButton!
    
    @IBAction func backBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "addDataMenuToMainMenu", sender: nil)
    }

    @IBAction func startNewSessionPressed(_ sender: Any) {
        performSegue(withIdentifier: "addDataToNewSession", sender: nil)
    }
    
    @IBAction func continuePrevSessionPressed(_ sender: Any) {
        performSegue(withIdentifier: "addMenuToContinueSession", sender: nil)
    }
    
    @IBAction func safetyBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "dataToSafety", sender: nil)
    }
    
    @IBAction func infoBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "dataToInfo", sender: nil)
        
    }
    
}
