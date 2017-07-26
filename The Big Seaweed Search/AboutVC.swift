//
//  AboutVC.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 08/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import UIKit

//AboutVC View Controller Class for 'About' section of app
class AboutVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func backBtnPressed(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
}
