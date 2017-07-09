//
//  ProfileOptionsVC.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 08/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import UIKit

class ProfileOptionsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func backBtnPressed(_ sender: Any) {
//        _ = navigationController?.popViewController(animated: true)
//        dismiss(animated: true, completion: nil)
        performSegue(withIdentifier: "optionsToMain", sender: nil)
    }

    @IBAction func editProfileBtnPressed(_ sender: Any) { performSegue(withIdentifier: "optionsToEditProfile", sender: nil)
    }
    
    @IBAction func viewProfileBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "optionsToViewProfile", sender: nil)
    }
    
    
}
