//
//  BrowseMenuVC.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 14/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import UIKit

class BrowseMenuVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

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
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
}
