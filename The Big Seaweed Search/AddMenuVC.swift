//
//  AddMenuVC.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 09/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import UIKit

class AddMenuVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func backBtnPressed(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func startNewSessionPressed(_ sender: Any) {
        performSegue(withIdentifier: "addDataToNewSession", sender: nil)
    }
    
    @IBAction func continuePrevSessionPressed(_ sender: Any) {
    }
    
    @IBAction func safetyBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "dataToSafety", sender: nil)
    }
    
    @IBAction func infoBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "dataToInfo", sender: nil)
        
    }
    
}
