//
//  NewSessionVC.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 09/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import MapKit


class NewSessionVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var beachImage: FancyImageView!
    @IBOutlet weak var dateTimeLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var gradientPicker: UIPickerView!
    @IBOutlet weak var beachPicker: UIPickerView!
    @IBOutlet weak var whoPicker: UIPickerView!
    
    let gradient = ["Flat","Gently Sloping","Steep"]
    let beach = ["Mostly sand","Mostly rock","Mixture"]
    let whoP = ["Just me","Family/friends (adults only)", "Family/friends (including children)", "Primary School", "Secondary School", "College/University", "Other youth group", "Adult volunteer group", "Other"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gradientPicker.delegate = self
        gradientPicker.dataSource = self
        beachPicker.delegate = self
        beachPicker.dataSource = self
        whoPicker.delegate = self
        whoPicker.dataSource = self
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == gradientPicker {
            return 1
        } else if pickerView == beachPicker {
            return 1
        } else if pickerView == whoPicker {
        return 1
        }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == gradientPicker {
            return gradient.count
        } else if pickerView == beachPicker {
            return beach.count
        } else if pickerView == whoPicker {
            return whoP.count
        }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == gradientPicker {
            return gradient[row]
        } else if pickerView == beachPicker {
            return beach[row]
        } else if pickerView == whoPicker {
            return whoP[row]
        }
        return ""
    }
    
    
    
    @IBAction func takePhoto(_ sender: Any) {
    }
    
    @IBAction func StartCollectingDataPressed(_ sender: Any) {
    }
    
    @IBAction func backPressed(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    
   }
