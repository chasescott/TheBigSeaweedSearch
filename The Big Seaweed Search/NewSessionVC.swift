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
import AVFoundation


class NewSessionVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var beachImage: FancyImageView!
    @IBOutlet weak var dateTimeLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var gradientPicker: UIPickerView!
    @IBOutlet weak var beachPicker: UIPickerView!
    @IBOutlet weak var whoPicker: UIPickerView!
    
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var imageSelected = false
    
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
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
    }
    
    @IBAction func prepareToTakePhoto(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func openLibrary(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            beachImage.image = image
            imageSelected = true
        } else {
            userAlertDoMore(alert: "A valid image was not selected.  Please try again")
            print("CHASE: A valid image wasn't selected")
        }
        //once image selected, dismiss picker view
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func StartCollectingDataPressed(_ sender: Any) {
        //userAlertSuccess(alert: "Your session has now been activated.  Please proceed to collect data")
    }
    
    //User alert windows to warn of issue that needs attention before proceeding
    func userAlertDoMore (alert: String) {
        let alertController = UIAlertController(title: "Problem!", message: alert, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert + 1;
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    //User alert to advise of success and perform segue to next screen
    func userAlertSuccess (alert: String) {
        let alertController = UIAlertController(title: "Success!", message: alert, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: {
            action in self.performSegue(withIdentifier: "", sender: nil)
        }))
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert + 1;
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alertController, animated: true, completion: nil)
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
    
    @IBAction func backPressed(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
   }
