//
//  AddDataVC.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 11/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import UIKit

class AddDataVC: UIViewController {

    private var _currentSession: Session!
    
    var currentSession: Session {
        get {
            return _currentSession
        } set {
            _currentSession = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func backBtnPressed(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
}
