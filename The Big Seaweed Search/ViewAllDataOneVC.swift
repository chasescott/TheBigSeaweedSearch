//
//  ViewAllDataOneVC.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 16/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class ViewAllDataOneVC: UIViewController {

    private var _currentData: DataPost?
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var img: UIImage? = nil
    
    var currentData: DataPost {
        get {
            return _currentData!
        } set {
            _currentData = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    
    @IBOutlet weak var backBtn: UIBarButtonItem!
    @IBAction func backBtnPressed(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
}
