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

///Start a New Session view controller
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
    //Firebase ref
    var rootRef:FIRDatabaseReference!
    //DataCounter for badge pop up
    var dataCounter: DataCounter!
    var newSession: Session!
    
    //picker view arrays for selection
    let gradient = ["Flat","Gently Sloping","Steep"]
    let beach = ["Mostly sand","Mostly rock","Mixture"]
    let whoP = ["Just me","Family/friends (adults only)", "Family/friends (including children)", "Primary School", "Secondary School", "College/University", "Other youth group", "Adult volunteer group", "Other"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Picker delegates set to self
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
    
    /// Method to ensure the app only lets the location be collated when app is in use, not in the background as that will drain the battery life quickly.
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
    
    /// Method to obtain location of user, store the GPS coordinates in the beachLocation variable, display the coordinates in the label on the view and stop the location manager from constantly updating in the background, thus saving battery.
    ///
    /// - Parameters:
    ///   - manager: CLLocationManager object to obtain exact coordinates
    ///   - locations: Array of CLLocation objects to store location info
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        let x = locValue.latitude
        let y = Double(round(1000000*x)/1000000)
        let w = locValue.longitude
        let z = Double(round(1000000*w)/1000000)
            locationLbl.text = ("Latitude: \(y) - Longitude: \(z)")
            beachLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
            locationManager.stopUpdatingLocation()
    }
    
    /// Determine if location authorization status changes at any time during use.
    ///
    /// - Parameters:
    ///   - manager: Stores CLLocationManager object to obtain exact coordinates
    ///   - status: Obtains CLAuthorizationStatus status to determine if the authorization status of the user changes
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            let locValue:CLLocationCoordinate2D = manager.location!.coordinate
            let x = locValue.latitude
            let y = Double(round(1000000*x)/1000000)
            let w = locValue.longitude
            let z = Double(round(1000000*w)/1000000)
            locationLbl.text = ("Latitude: \(y) - Longitude: \(z)")
            beachLocation = CLLocation()
            locationManager.stopUpdatingLocation()
        }
    }
    
    /// Capture image using the device's camera
    ///
    /// - Parameter sender: Any - Data from the camera
    @IBAction func prepareToTakePhoto(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    /// Capture existing image from the device's library
    ///
    /// - Parameter sender: Any - Data from the camera
    @IBAction func openLibrary(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    /// Check to see if image picker media has been selected
    ///
    /// - Parameters:
    ///   - picker: The UIImagePicker
    ///   - info: What info is currently being stored in the UIImagePicker
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
    
    /// Method to run when the Save button is pressed.  Take the image in the picker viewer, create a string to unique identify the image, upload the image to Firebase storage and then run the postToFirebase method.
    ///
    /// - Parameter sender: Data relating to the image.
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
    
    /// Method to post all data to Firebase nodes as Dictionary object (including GeoFire coordinates).
    ///1.  generates an auto ID and then inserts post object above into Firebase
    ///2.  takes the firebasePost auto ID key and stores in firebaseKey constant
    ///3.  stores key in user section of firebase under 'sessions'
    ///4.  stores sessions key under 'users' section of firebase
    ///5. Store CL coordinates for session in firebase...
    ///6. Run code to increase by 1 the number of sessionss the user has created against the USER node in Firebase
    ///7. Upload number of session to Leaderboard FB nodes
    ///8. Run badge check to see if new badge to be awarded, if so, present congratulatory message
    ///9. Run code to count the number of posts in the given session and add number of sessions data to sessions node
    ///10. Reset visible elements/fields within the view.
    ///
    /// - Parameters:
    ///   - imgUrl: The URL of the image storage location on Firebase
    ///   - endAlert: Data to pass through to checkBadges() method
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
                numbOfSessions = numbOfSessions + 1
                print("The number of posts is: \(numbOfSessions)")
                DataService.ds.REF_USERS.child(userId).child("numberOfSessions").setValue(numbOfSessions)
                //Upload number of posts to Leaderboard FB nodes
                DataService.ds.REF_LEADERBOARD.child(userId).child("numberOfSessions").setValue(numbOfSessions)
                self.checkBadges(numbOfSessions: numbOfSessions)
            })
//            imageSelected = false
            //beachImage.image = UIImage(named: "beach")
//            userAlertSuccess(alert: "Your session has now been activated.  Please continue to collect data")
            print("CHASE: New Session Activated")
        }
    }
    
    /// Check the number of sessions a user has uploaded.  If number is equal to the value of a badge, then pop up modal segue to imageView with a badge awarding user
    ///
    /// - Parameters:
    ///   - numberOfPosts: Int - the total number of posts a user has uploaded
    ///   - endAlert: String representing the alert to show the user - i.e. "Congratulations you've earned a badge!  Your data added successfully. Please press ok to continue"
    func checkBadges (numbOfSessions: Int) {
        if numbOfSessions == 1 {
            imageSelected = false
            self.dataCounter = DataCounter(count: numbOfSessions, isPostType: false)
            performSegue(withIdentifier: "sessionToBadgePopUpVC", sender: self)
        } else if numbOfSessions == 5 {
            imageSelected = false
            self.dataCounter = DataCounter(count: numbOfSessions, isPostType: false)
            performSegue(withIdentifier: "sessionToBadgePopUpVC", sender: self)
        } else if numbOfSessions == 10 {
            imageSelected = false
            self.dataCounter = DataCounter(count: numbOfSessions, isPostType: false)
            performSegue(withIdentifier: "sessionToBadgePopUpVC", sender: self)
        } else if numbOfSessions == 15 {
            imageSelected = false
            self.dataCounter = DataCounter(count: numbOfSessions, isPostType: false)
            performSegue(withIdentifier: "sessionToBadgePopUpVC", sender: self)
        } else if numbOfSessions == 20 {
            imageSelected = false
            self.dataCounter = DataCounter(count: numbOfSessions, isPostType: false)
            performSegue(withIdentifier: "sessionToBadgePopUpVC", sender: self)
        } else if numbOfSessions == 25 {
            imageSelected = false
            self.dataCounter = DataCounter(count: numbOfSessions, isPostType: false)
            performSegue(withIdentifier: "sessionToBadgePopUpVC", sender: self)
        } else {
            imageSelected = false
            userAlertSuccess(alert: "Your session has now been activated.  Please continue to collect data")
        }
    }
    
    ///Pass through session object containing session data to add data VC
    ///
    /// - Parameters:
    ///   - segue: The id of the segue to be initiated
    ///   - sender: The data that is to be sent.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Store variables in session object to pass through
        let userId = FIRAuth.auth()?.currentUser?.uid
        sessionName = nameLbl.text!
        self.newSession = Session(sessionId: sessionId, imgURL: imageLink, userId: userId!, date: dateAsString, whoWith: whoSelected, beachType: beachSelected, beachGradient: gradientSelected, numberOfPosts: numberOfPosts, sessionName: sessionName)
        //Pass session object via segue to new AddDataVC
        if let destinationVC = segue.destination as?
            AddDataVC {
            destinationVC.currentSession = newSession
        } else if let destinationVC = segue.destination as? BadgePopUpVC {
            destinationVC.dataCounter = dataCounter
            destinationVC.currentSession = newSession
        }
        }
    
    ///User alert windows to warn of issue that needs attention before proceeding
    ///
    /// - Parameter alert: String to represent warning that needs to pop up
    func userAlertDoMore (alert: String) {
        let alertController = UIAlertController(title: "Problem!", message: alert, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert + 1;
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    ///User alert windows to advise of success and segue to next screen
    ///
    /// - Parameter alert: String to represent congratulations that needs to pop up
    func userAlertSuccess (alert: String) {
        let alertController = UIAlertController(title: "Success!", message: alert, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler:
            {
            action in self.performSegue(withIdentifier: "sessionToAdd", sender: self)
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
