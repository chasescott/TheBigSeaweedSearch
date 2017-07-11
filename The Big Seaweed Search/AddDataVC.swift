//
//  AddDataVC.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 11/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import MapKit
import AVFoundation

class AddDataVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {

    private var _currentSession: Session!
    @IBOutlet weak var imageAdd: FancyImageView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var seaweedPicker: UIPickerView!
    
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
    var seaweedType: String!
    //Geofire variables
    var geoFire: GeoFire!
    let ref = FIRDatabase.database().reference()
    //post variables
    var imageLink: String!
    var postId: String!
    var sessionId: String!
    
    //picker view array for selection
    let seaweed = ["Dabberlocks  - (native)", "Sugar Kelp  - (native)", "Serrated Wrack  - (native)", "Bladder Wrack  - (native)", "Knotted Wrack  - (native)", "Spiral Wrack  - (native)", "Channelled Wrack  - (native)", "Thongweed  - (native)", "Wireweed - (non-native)", "Wakame  - (non-native)", "Harpoon Weed - (non-native)", "Bonnemaison's Hook - (non-native)"]
    
    //getters & setters for Session object
    var currentSession: Session {
        get {
            return _currentSession
        } set {
            _currentSession = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        seaweedPicker.delegate = self
        seaweedPicker.dataSource = self
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        formatter.dateFormat = "dd/MM/yyyy"
        let dateString = "Session Date: \(formatter.string(from: date as Date))"
        dateLbl.text = String(dateString)
        dateAsString = formatter.string(from: date as Date)
        sessionId = currentSession.sessionId
    }
    
    override func viewDidAppear(_ animated: Bool) {
        locationAuthStatus()
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
        locationLbl.text = ("locations = \(locValue.latitude) \(locValue.longitude)")
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
    
    @IBAction func imageCapture(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    //CHASE:  Select Image function
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageAdd.image = image
            imageSelected = true
        } else {
            userAlertDoMore(alert: "A valid image was not selected.  Please try again")
            print("CHASE: A valid image wasn't selected")
        }
        //once image selected, dismiss picker view
        imagePicker.dismiss(animated: true, completion: nil)
    }

    
    @IBAction func saveBtnPressed(_ sender: Any) {
        guard let img = imageAdd.image, imageSelected == true else {
            userAlertDoMore(alert: "Please capture an image of the seaweed you are recording")
            print("CHASE: An image must be selected")
            return
        }
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            //creates a string to unique identify items
            let imgUid = NSUUID().uuidString
            
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            //Attempts to upload image to firebase and store URL link in variable
            DataService.ds.REF_POST_IMAGES.child(imgUid).put(imgData, metadata: metadata) { (metadata, error) in
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
        userAlertSuccess(alert: "Data added successfully! Please press ok to continue and add more")
    }
    
    func postToFirebase(imgUrl: String) {
        let geoFire = GeoFire(firebaseRef: ref.child("location").child("posts"))
        let sessionIdentity = sessionId as String
        if let userId = FIRAuth.auth()?.currentUser?.uid {
            let addData: Dictionary<String, AnyObject> = [
                "userid": userId as AnyObject,
                "date": "\(formatter.string(from: date as Date))" as AnyObject, //store date as string in Firebase
                "seaweedType": seaweedType as AnyObject,
                "sessionid": sessionId as AnyObject,
                "photoURL": imgUrl as AnyObject
            ]
            //1.  generates an auto ID and then inserts post object above into Firebase
            let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
            firebasePost.setValue(addData)
            
            //2.  takes the firebasePost auto ID key and stores in firebaseKey constant
            let firebaseKey = firebasePost.key
            postId = firebaseKey
            
            //3.  stores key in user section of firebase under 'posts'
            FIRDatabase.database().reference().child("users/\(userId)/posts").child(firebaseKey).setValue(true)
            
            //4.  stores post key under 'sessions' section of firebase
            FIRDatabase.database().reference().child("sessions/\(sessionIdentity)/posts").child(firebaseKey).setValue(true)
            
            //5. Store CL coordinates for post in firebase...
            geoFire!.setLocation(beachLocation, forKey: firebaseKey)
            
            //6. Run code to count number of posts user has created
        
            //7. Reset form
            imageSelected = false
            imageAdd.image = UIImage(named: "add-image")
            print("CHASE: New Post Successful")
        }
    }
    
    @IBAction func endSessionBtnPressed(_ sender: Any) {
        guard let img = imageAdd.image, imageSelected == true else {
                userAlertFinishCheck()
                return
        }
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            //creates a string to unique identify items
            let imgUid = NSUUID().uuidString
            
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            //Attempts to upload image to firebase and store URL link in variable
            DataService.ds.REF_POST_IMAGES.child(imgUid).put(imgData, metadata: metadata) { (metadata, error) in
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
        userAlertFinishCheck()
    }
    
    @IBAction func helpBtnPressed(_ sender: Any) {
        //TBC pop over window
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
    
    //User alert to advise of success
    func userAlertSuccess (alert: String) {
        let alertController = UIAlertController(title: "Success!", message: alert, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil
        ))
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert + 1;
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    //User alert to advise session ended and perform segue back to main screen
    func userAlertFinishCheck () {
        let alertController = UIAlertController(title: "End Session", message: "Are you sure you want to finish?", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {
            action in self.performSegue(withIdentifier: "addDataVCtoAddDataMenu", sender: nil)
        }
        ))
        alertController.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
    
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert + 1;
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alertController, animated: true, completion: nil)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return seaweed.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return seaweed[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        seaweedType = seaweed[row] as String
    }
    
    @IBAction func instructionsBtnPressed(_ sender: Any) { performSegue(withIdentifier: "addDataToInstructions", sender: nil)
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
        performSegue(withIdentifier: "addDataVCtoAddDataMenu", sender: nil)
    }
}
