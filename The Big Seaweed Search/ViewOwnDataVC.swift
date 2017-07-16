//
//  ViewOwnDataVC.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 14/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import SwiftKeychainWrapper

class ViewOwnDataVC: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    private var _currentSession: Session!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sessionLbl: UILabel!
    @IBOutlet weak var nameLbl: UINavigationItem!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var beachTypeLbl: UILabel!
    @IBOutlet weak var gradientLbl: UILabel!
    @IBOutlet weak var numberLbl: UILabel!
    @IBOutlet weak var picture: FancyImageView!
    
    //Table view variables
    var userposts = [UserPost]()
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    //GPS location storage variables
    let locationManager = CLLocationManager()
    //Geofire variables
    var geoFire: GeoFire!
    let ref = FIRDatabase.database().reference()
    var img: UIImage? = nil
    
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
        view.backgroundColor = UIColor.white
        tableView.delegate = self
        tableView.dataSource = self
        
        sessionLbl.text = currentSession.sessionName
        dateLbl.text = currentSession.date
        beachTypeLbl.text = currentSession.beachType
        gradientLbl.text = currentSession.beachGradient
        numberLbl.text = "\(currentSession.numberOfPosts)"
        
        if img != nil {
            self.picture.image = img
        } else {
            let ref = FIRStorage.storage().reference(forURL: currentSession.imgURL)
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("CHASE: Unable to download image from Firebase storage")
                } else {
                    print("CHASE: Image downloaded from Firebase Storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData)
                        {
                            self.picture.image = img
                            ViewOwnDataVC.imageCache.setObject(img, forKey: self.currentSession.imgURL as NSString)
                        }
                    }
                }
        })
        }

        appendUserPostsData()
        self.userposts.reverse()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userposts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userpost = userposts[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "UserDataListCell", for: indexPath) as? UserDataListCell {
            if let img = ViewOwnDataVC.imageCache.object(forKey: userpost.photoURL as NSString) {
                cell.configureCell(userpost: userpost, img: img) }
                    else {
                        cell.configureCell(userpost: userpost)
                    }
                    return cell
                } else {
                    return UserDataListCell()
                }
            }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentUserPost = userposts[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showOwnDataFromList", sender: currentUserPost)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ViewOwnDataPopOverVC {
            if let currentUserPost = sender as? UserPost {
                destination.currentUserPost = currentUserPost
            }
        }
    }
    
    func appendUserPostsData() {
        let geoFire = GeoFire(firebaseRef: ref.child("location").child("posts"))
        var seaweedLocation = CLLocation()
        let sessionID = currentSession.sessionId
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            self.userposts = []
            DataService.ds.REF_SESSIONS.child(sessionID).child("posts").observeSingleEvent(of: .value, with: { snapshot in
            print (snapshot.childrenCount) //get the expected number of post items
            let enumerator = snapshot.children //start iterating through post items
                while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                    print("CHASE: Post KEY - \(rest.key)")
                    let anotherKey: String = rest.key
                    //Start iterating through posts node on Firebase to find details of sessions found to be allocated ot that specific user as found above
                    DataService.ds.REF_POSTS.child(anotherKey).observeSingleEvent(of: .value, with: { (snapshot) in
                        let postValue = snapshot.value as? Dictionary<String, AnyObject>
                        let date = postValue?["date"] as? String ?? ""
                        let seaweedType = postValue?["seaweedType"] as? String ?? ""
                        let photoURL = postValue?["photoURL"] as? String ?? ""
                        let sessionId = postValue?["sessionid"] as? String ?? ""
                    //Go to GeoFire to obtain post co-ordinates and build/append userpost object within this area of code
                        geoFire!.getLocationForKey(anotherKey, withCallback: { (location, error) in
                            if let location = location {
                                seaweedLocation = location
                                print("CHASE: Geofire Location stored")
                                print("Seaweed Lat: \(seaweedLocation.coordinate.latitude)")
                                print("Seaweed Lon: \(seaweedLocation.coordinate.longitude)")
                                let newPost = UserPost(postKey: anotherKey, date: date, userId: uid, seaweedType: seaweedType, photoURL: photoURL, sessionId: sessionId, location: seaweedLocation)
                                self.userposts.append(newPost)
                                self.tableView.reloadData()
                                print("CHASE: Post key \(newPost.postKey!)")
                                print("CHASE: Post date \(newPost.date!)")
                                print("CHASE: Post UID \(newPost.userId!)")
                                print("CHASE: Post Seaweed Type \(newPost.seaweedType!)")
                                print("CHASE: Post PhotoURL \(newPost.photoURL!)")
                                print("CHASE: Post Session \(newPost.sessionId!)")
                                print("CHASE: Post Latitude \(newPost.lati!)")
                                print("CHASE: Post Longitude \(newPost.longi!)")
                                print("CHASE: POSTS IN ARRAY: \(self.userposts.count)")
                            } else {
                               self.userAlertDoMore(alert: "Unable to load data information. Please try again later")
                            }
                        })
                })
            }
            })
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
            alertWindow.rootViewController?.present(alertController, animated: true, completion: {
                self.dismiss(animated: true, completion: nil)
            })
        }
    
    @IBAction func backBtn(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
}
