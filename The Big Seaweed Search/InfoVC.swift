//
//  infoVC.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 05/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import UIKit

class InfoVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func backBtn(_ sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func instructionsBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "infoToInstructions", sender: nil)
    }
    
    @IBAction func aboutBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "infoToAbout", sender: nil)
    }
    
    @IBOutlet weak var privacyBtnPressed: FancyButton!
    
    @IBAction func privacyPressed(_ sender: Any) { performSegue(withIdentifier: "infoToPrivacy", sender: nil)
    }
}
