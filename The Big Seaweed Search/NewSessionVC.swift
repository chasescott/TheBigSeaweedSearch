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

class NewSessionVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, UITextFieldDelegate {

    @IBOutlet weak var beachImage: FancyImageView!
    @IBOutlet weak var dateTimeLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var gradientPicker: UIPickerView!
    @IBOutlet weak var beachPicker: UIPickerView!
    @IBOutlet weak var whoPicker: UIPickerView!
    @IBOutlet weak var nameLbl: FancyField!
    
    //Camera & picker view variables
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var imageSelected = false
    //Date constants
    let date = NSDate()
    let formatter = DateFormatter()
    var dateAsString: String!
    //GPS location storage variables
    let locationManager = CLLocationManager()
    var beachLocation = CLLocation()
    //picker view value storage variables
    var beachSelected: String = "Mostly Sand"
    var gradientSelected: String = "Flat"
    var whoSelected: String = "Just me"
    //Geofire variables
    var geoFire: GeoFire!
    let ref = FIRDatabase.database().reference()
    //Session object
    var imageLink: String!
    var numberOfPosts: Int = 0
    var sessionName: String!
//    var session: Session!
    var sessionId: String!
    
    //picker view arrays for selection
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
        formatter.dateFormat = "dd/MM/yyyy"
        let dateString = "Session Date: \(formatter.string(from: date as Date))"
        dateTimeLbl.text = String(dateString)
        dateAsString = formatter.string(from: date as Date)
        nameLbl.delegate = self
        }
    
    override func viewDidAppear(_ animated: Bool) {
        locationAuthStatus()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameLbl.resignFirstResponder()
        return false
    }
    
    func locationAuthStatus() {
        //Only let location be collated when app is in use, not in the background as that will drain the battery life quickly.
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            if CLLocationManager.locationServicesEnabled() {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.startUpdatingLocation()
            }
        } else {
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
            locationLbl.text = ("Latitude: \(locValue.latitude) - Longitude: \(locValue.longitude)")
            beachLocation = CLLocation()
            locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            let locValue:CLLocationCoordinate2D = manager.location!.coordinate
            locationLbl.text = ("locations = \(locValue.latitude) \(locValue.longitude)")
            beachLocation = CLLocation()
            locationManager.stopUpdatingLocation()
        }
    }
    
    //CHASE:  Camera Function
    @IBAction func prepareToTakePhoto(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    //CHASE:  Library access function
    @IBAction func openLibrary(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    //CHASE:  Select Image function
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
        guard let name = nameLbl.text, name != "" else {
            userAlertDoMore(alert: "Please enter a session name for future reference.  This can be anything you want, but it might be helpful if you include the beach name")
            return
        }
        guard let img = beachImage.image, imageSelected == true else {
            userAlertDoMore(alert: "Please upload an image of the beach area you are surveying")
            print("CHASE: An image must be selected")
            return
        }
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            //creates a string to unique identify items
            let imgUid = NSUUID().uuidString
            
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            //Attempts to upload image to firebase and store URL link in variable
            DataService.ds.REF_SESSION_IMAGES.child(imgUid).put(imgData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    self.userAlertDoMore(alert: "Unable to upload image.  Please try again")
                    print("CHASE: Unable to upload image to Firebase Storage")
                } else {
                    print("CHASE: Successfully uploaded image to Firebase Storage")
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    if let url = downloadURL {
                        self.imageLink = url
                        self.postToFirebase(imgUrl: url)
                    }
                }
            }
        }
    }
    
    func postToFirebase(imgUrl: String) {
        let geoFire = GeoFire(firebaseRef: ref.child("location").child("sessions"))
        if let userId = FIRAuth.auth()?.currentUser?.uid{
            let sessionData: Dictionary<String,AnyObject> = [
                "userid": userId as AnyObject,
                "date": "\(formatter.string(from: date as Date))" as AnyObject, //store date as string in Firebase
                "whoWith": whoSelected as AnyObject,
                "beachType": beachSelected as AnyObject,
                "beachGradient": gradientSelected as AnyObject,
                "numberOfPosts": numberOfPosts as AnyObject,
                "sessionName": nameLbl.text! as AnyObject,
                "photoURL": imgUrl as AnyObject
            ]
            
            //generates an auto ID and then inserts post object above into Firebase
            let firebasePost = DataService.ds.REF_SESSIONS.childByAutoId()
            firebasePost.setValue(sessionData)
            
            //takes the firebasePost key and stores in firebaseKey constant
            let firebaseKey = firebasePost.key
            sessionId = firebaseKey
            
            //stores key in user section of firebase under 'sessions'
            FIRDatabase.database().reference().child("users/\(userId)/sessions").child(firebaseKey).setValue(true)
            
            //Store CL coordinates in firebase...
            geoFire!.setLocation(beachLocation, forKey: firebaseKey)
            
            //Increase by 1 the number of sessions the user has created against the User node in Firebase
            DataService.ds.REF_USERS.child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                var numbOfSessions = value?["numberOfSessions"] as! Int
                print("The number of posts is: \(numbOfSessions)")
                numbOfSessions = numbOfSessions + 1
                DataService.ds.REF_USERS.child(userId).child("numberOfSessions").setValue(numbOfSessions)
                //Upload number of posts to Leaderboard FB nodes
                DataService.ds.REF_LEADERBOARD.child(userId).child("numberOfSessions").setValue(numbOfSessions)
            })

            
            imageSelected = false
            //beachImage.image = UIImage(named: "beach")
            userAlertSuccess(alert: "Your session has now been activated.  Please continue to collect data")
            print("CHASE: New Session Activated")
        }
    }
    
    //Pass through session object containing session data to add data VC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Store variables in session object to pass through
        let userId = FIRAuth.auth()?.currentUser?.uid
        sessionName = nameLbl.text!
        let newSession = Session(sessionId: sessionId, imgURL: imageLink, userId: userId!, date: dateAsString, whoWith: whoSelected, beachType: beachSelected, beachGradient: gradientSelected, numberOfPosts: numberOfPosts, sessionName: sessionName)
        //Pass session object via segue to new AddDataVC
        if let destinationVC = segue.destination as?
            AddDataVC{
            destinationVC.currentSession = newSession
            }
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
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler:
            {
            action in self.performSegue(withIdentifier: "sessionToAdd", sender: nil)
        }
        ))
        
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == gradientPicker {
            gradientSelected = gradient[row] as String
        } else if pickerView == beachPicker {
            beachSelected = beach[row] as String
        } else if pickerView == whoPicker {
            whoSelected = whoP[row] as String
        }
    }
    
    @IBAction func backPressed(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
   }
