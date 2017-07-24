//
//  BrowseMenuVC.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 14/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import UIKit
import Firebase

class BrowseMenuVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            DataService.ds.REF_USERS.child(uid).observe(.value, with: { snapshot in
                let sessionsValue = snapshot.value as? Dictionary<String,AnyObject>
                let numberOfSessions = sessionsValue?["numberOfSessions"] as! Int
                let numberOfPosts = sessionsValue?["numberOfPosts"] as! Int
                if numberOfSessions == 0 && numberOfPosts == 0 {
                    self.myList.isEnabled = false
                    self.myMap.isEnabled = false
                } else {
                    self.myList.isEnabled = true
                    self.myMap.isEnabled = true
                }
            })
        }
    }

    @IBOutlet weak var myList: FancyButton!
    @IBOutlet weak var myMap: FancyButton!
    
    @IBAction func myDataList(_ sender: Any) {
        performSegue(withIdentifier: "browseMenuToDataList", sender: nil)
    }
    
    @IBAction func myDataMap(_ sender: Any) {
        performSegue(withIdentifier: "browseDataMenuToViewOwnDataMapVC", sender: nil)
    }
    
    @IBAction func allDataList(_ sender: Any) {
        performSegue(withIdentifier: "browseToViewAllData", sender: nil)
    }
    
    @IBAction func allDataMap(_ sender: Any) {
        performSegue(withIdentifier: "browseDataToViewAllOnMapVC", sender: nil)
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
}
