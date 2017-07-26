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

///AddDataVC View Controller Class for 'Add Data' section of app
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
    var seaweedType: String = "Dabberlocks  - (native)"
    //Geofire variables
    var geoFire: GeoFire!
    let ref = FIRDatabase.database().reference()
    //post variables
    var imageLink: String!
    var postId: String!
    var sessionId: String!
    //Firebase reference
    var postsRef: FIRDatabaseReference!
    var numberOfPosts: Int!
    //Firebase ref
    var rootRef:FIRDatabaseReference!
    var dataCounter: DataCounter!
    
    //picker view array for selection
    let seaweed = ["Dabberlocks  - (native)", "Sugar Kelp  - (native)", "Serrated Wrack  - (native)", "Bladder Wrack  - (native)", "Knotted Wrack  - (native)", "Spiral Wrack  - (native)", "Channelled Wrack  - (native)", "Thongweed  - (native)", "Wireweed - (non-native)", "Wakame  - (non-native)", "Harpoon Weed - (non-native)", "Bonnemaison's Hook - (non-native)"]
    
    //Getters & Setters for currentSession object passed through from 'NewSessionVC' or 'ContinueSessionVC'
    var currentSession: Session {
        get {
            return _currentSession
        } set {
            _currentSession = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Picker delegates set to self
        seaweedPicker.delegate = self
        seaweedPicker.dataSource = self
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        formatter.dateFormat = "dd/MM/yyyy"
        let dateString = "Session Date: \(formatter.string(from: date as Date))"
        if currentSession.date != ""  {
            dateLbl.text = "Session Date: \(currentSession.date)"
        } else {
        dateLbl.text = String(dateString)
        }
        dateAsString = formatter.string(from: date as Date)
        sessionId = currentSession.sessionId
    }
    
    override func viewDidAppear(_ animated: Bool) {
        locationAuthStatus()
    }
    
    /// Method to ensure the app only lets the location be collated when app is in use, not in the background as that will drain the battery life quickly.
    func locationAuthStatus() {
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
            locationLbl.text = ("locations = \(locValue.latitude) \(locValue.longitude)")
            beachLocation = CLLocation()
            locationManager.stopUpdatingLocation()
        }
    }
    
    /// Capture image using the device's camera
    ///
    /// - Parameter sender: Any - Data from the camera
    @IBAction func imageCapture(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
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
            imageAdd.image = image
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
                        self.postToFirebase(imgUrl: url, endAlert: false)
                    }
                }
            }
        }
        //userAlertSuccess(alert: "Data added successfully! Please press ok to continue and add more")
    }
    
    /// Method to post all data to Firebase nodes as Dictionary object (including GeoFire coordinates).
    ///1.  generates an auto ID and then inserts post object above into Firebase
    ///2.  takes the firebasePost auto ID key and stores in firebaseKey constant
    ///3.  stores key in user section of firebase under 'posts'
    ///4.  stores post key under 'sessions' section of firebase
    ///5. Store CL coordinates for post in firebase...
    ///6. Run code to increase by 1 the number of posts the user has created against the USER node in Firebase
    ///7. Upload number of posts to Leaderboard FB nodes
    ///8. Run badge check to see if new badge to be awarded, if so, present congratulatory message
    ///9. Run code to count the number of posts in the given session and add number of posts data to sessions node
    ///10. Reset visible elements/fields within the view.
    ///
    /// - Parameters:
    ///   - imgUrl: The URL of the image storage location on Firebase
    ///   - endAlert: Data to pass through to checkBadges() method
    func postToFirebase(imgUrl: String, endAlert: Bool) {
        let geoFire = GeoFire(firebaseRef: ref.child("location").child("posts"))
        let sessionIdentity = sessionId as String
        let numberOfLikes: Int = 0
        if let userId = FIRAuth.auth()?.currentUser?.uid {
            let addData: Dictionary<String, AnyObject> = [
                "userid": userId as AnyObject,
                "date": "\(formatter.string(from: date as Date))" as AnyObject, //store date as string in Firebase
                "seaweedType": seaweedType as AnyObject,
                "sessionid": sessionId as AnyObject,
                "numberOfLikes": numberOfLikes as AnyObject,
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
            
            //6. Run code to increase by 1 the number of posts the user has created against the USER node in Firebase
            DataService.ds.REF_USERS.child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                self.numberOfPosts = value?["numberOfPosts"] as! Int
                self.numberOfPosts = self.numberOfPosts + 1
                print("The number of posts is: \(self.numberOfPosts!)")
                DataService.ds.REF_USERS.child(userId).child("numberOfPosts").setValue(self.numberOfPosts)
                //Upload number of posts to Leaderboard FB nodes
                DataService.ds.REF_LEADERBOARD.child(userId).child("numberOfPosts").setValue(self.numberOfPosts)
                //Run badge check to see if new badge to be awarded, if so, present congratulatory message
                if endAlert == true {
                    self.checkBadges(numberOfPosts: self.numberOfPosts, endAlert: true)
                } else if endAlert == false {
                    self.checkBadges(numberOfPosts: self.numberOfPosts, endAlert: false)
                }
            })
            
            //.7  Run code to count the number of posts in the given session and add number of posts data to sessions node
            DataService.ds.REF_SESSIONS.child(sessionId).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                var numbOfPosts = value?["numberOfPosts"] as! Int
                print("The number of posts in this session is: \(numbOfPosts)")
                numbOfPosts = numbOfPosts + 1
                DataService.ds.REF_SESSIONS.child(self.sessionId).child("numberOfPosts").setValue(numbOfPosts)
            })

            //8. Reset form
            imageSelected = false
            imageAdd.image = UIImage(named: "add-image")
            print("CHASE: New Post Successful")
        }
    }
    
    /// Method to adjust the total number of posts for the user
    ///
    /// - Parameter addPost: Bool to state increase (i.e. true) or decrease (i.e. false)
    func adjustNumberOfPosts(addPost:Bool){
        if let userId = FIRAuth.auth()?.currentUser?.uid {
        if addPost {
            numberOfPosts = numberOfPosts + 1
        } else {
            numberOfPosts = numberOfPosts - 1
        }
        DataService.ds.REF_USERS.child(userId).child("numberOfPosts").setValue(numberOfPosts)
            print("CHASE: number of posts should increase")
    }
}

    
    /// Method to run when the End session button is pressed.  Take the image in the picker viewer, create a string to unique identify the image, upload the image to Firebase storage and then run the postToFirebase method.  Finally, run alert to close session.
    ///
    /// - Parameter sender: Data relating to the image.
    @IBAction func endSessionBtnPressed(_ sender: Any) {
        guard let img = imageAdd.image, imageSelected == true else {
                userAlertFinishCheck()
                return
        }
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            //creates a unique string to identify items
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
                        self.postToFirebase(imgUrl: url, endAlert: true)
                    }
                }
            }
        }
        //userAlertFinishCheck()
    }
    
    
    /// Check the number of posts a user has uploaded.  If number is equal to the value of a badge, then pop up modal segue to imageView with a badge awarding user
    ///
    /// - Parameters:
    ///   - numberOfPosts: Int - the total number of posts a user has uploaded
    ///   - endAlert: String representing the alert to show the user - i.e. "Congratulations you've earned a badge!  Your data added successfully. Please press ok to continue"
    func checkBadges(numberOfPosts: Int, endAlert: Bool) {
        if numberOfPosts == 1 {
            imageSelected = false
            self.dataCounter = DataCounter(count: numberOfPosts, isPostType: true)
            performSegue(withIdentifier: "showDataPopOverVC", sender: self)
            if endAlert == false {
                userAlertSuccess(alert: "Congratulations you've earned a badge!  Your data added successfully. Please press ok to continue")
            } else {
                userAlertFinishCheck()
            }
        } else if numberOfPosts == 5 {
            imageSelected = false
            self.dataCounter = DataCounter(count: numberOfPosts, isPostType: true)
            performSegue(withIdentifier: "showDataPopOverVC", sender: self)
            if endAlert == false {
                userAlertSuccess(alert: "Congratulations you've earned a badge!  Your data added successfully. Please press ok to continue")
            } else {
                userAlertFinishCheck()
            }
        } else if numberOfPosts == 10 {
            imageSelected = false
            self.dataCounter = DataCounter(count: numberOfPosts, isPostType: true)
            performSegue(withIdentifier: "showDataPopOverVC", sender: self)
            if endAlert == false {
                userAlertSuccess(alert: "Congratulations you've earned a badge!  Your data added successfully. Please press ok to continue")
            } else {
                userAlertFinishCheck()
            }
        } else if numberOfPosts == 15 {
            imageSelected = false
            self.dataCounter = DataCounter(count: numberOfPosts, isPostType: true)
            performSegue(withIdentifier: "showDataPopOverVC", sender: self)
            if endAlert == false {
                userAlertSuccess(alert: "Congratulations you've earned a badge!  Your data added successfully. Please press ok to continue")
            } else {
                userAlertFinishCheck()
            }
        } else if numberOfPosts == 20 {
            imageSelected = false
            self.dataCounter = DataCounter(count: numberOfPosts, isPostType: true)
            performSegue(withIdentifier: "showDataPopOverVC", sender: self)
            if endAlert == false {
                userAlertSuccess(alert: "Congratulations you've earned a badge!  Your data added successfully. Please press ok to continue")
            } else {
                userAlertFinishCheck()
            }
        } else if numberOfPosts == 25 {
            imageSelected = false
            self.dataCounter = DataCounter(count: numberOfPosts, isPostType: true)
            performSegue(withIdentifier: "showDataPopOverVC", sender: self)
            if endAlert == false {
                userAlertSuccess(alert: "Congratulations you've earned a badge!  Your data added successfully. Please press ok to continue")
            } else {
                userAlertFinishCheck()
            }
        } else {
            imageSelected = false
            if endAlert == false {
            userAlertSuccess(alert: "Data added successfully! Please press ok to continue and add more")
            } else {
                userAlertFinishCheck()
            }
    }
    }
    
    @IBAction func helpBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "showSeaweedTypes", sender: nil)
    }
    
    /// Prepare for segue to push dataCounter object to badge pop up view to show how many posts a user has created and thus which badge is to be awarded
    ///
    /// - Parameters:
    ///   - segue: The id of the segue to be initiated
    ///   - sender: The data that is to be sent.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? AddDataBadgePopUpVC {
            destinationVC.dataCounter = dataCounter
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
    
    ///User alert windows to advise of success
    ///
    /// - Parameter alert: String to represent congratulations that needs to pop up
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
    
    ///User alert windows to warn session ended and segue back to the main screen.
    ///
    /// - Parameter alert: String to represent warning that needs to pop up
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
