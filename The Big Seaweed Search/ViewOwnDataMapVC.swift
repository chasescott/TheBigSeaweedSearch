//
//  ViewOwnDataMapVC.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 16/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import SwiftKeychainWrapper

///View own data on a map view controller
class ViewOwnDataMapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    //Map view variables
    @IBOutlet weak var mkMapView: MKMapView!
    let regionRadius: CLLocationDistance = 5000
    //Locations array for map
    var locations = [UserPost]()
    //Img Cache
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    //GPS location storage variables
    let locationManager = CLLocationManager()
    var userLocation = CLLocation()
    //Geofire variables
    var geoFire: GeoFire!
    let ref = FIRDatabase.database().reference()
    var img: UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        locationManager.delegate = self
        mkMapView.delegate = self
        let locValue:CLLocationCoordinate2D = locationManager.location!.coordinate
        let initialLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        centerMapOnLocation(location: initialLocation)
        
        appendUserPostsDataMapAnnotations()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        locationAuthStatus()
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
            userLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
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
            userLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
            locationManager.stopUpdatingLocation()
        }
    }

    /// Centers map on user's location
    ///
    /// - Parameter location: Users location as CLLocation object
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mkMapView.setRegion(coordinateRegion, animated: true)
    }
    
    /// Creates annotations for map view pins
    ///
    /// - Parameters:
    ///   - mapView: mapView
    ///   - annotation: The annotation object
    /// - Returns: the annotation view object
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // 3
            let identifier = "pin"
            var view: MKPinAnnotationView
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
            view.rightCalloutAccessoryView?.backgroundColor = UIColor.darkGray
            print("CHASE: Made annotation")
        return view
        }
    
    /// MapView annotation pin tapped action
    ///
    /// - Parameters:
    ///   - mapView: map view object
    ///   - view: the view used in the pin annotation
    ///   - control: the type of control object
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            let annotation = view.annotation as! UserPostAnnotation
            performSegue(withIdentifier: "viewOwnDataOverMapPopover", sender: annotation)
        }
    
    ///Pass through session object containing session data to the next view controller
    ///
    /// - Parameters:
    ///   - segue: The id of the segue to be initiated
    ///   - sender: The data that is to be sent.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ViewOwnDataMapPopOverVC {
            if let currentUserAnnotation = sender as? UserPostAnnotation {
                destination.currentUserAnnotation = currentUserAnnotation
            }
        }
        }

        /// Annotations added to the map.  Run at viewDidLoad() and looks to Firebase to run GeoFire query and locate the nearest post objects around the users location and then returns the top X values.  The post and user data is pulled from Firebase and attached to the annotation objects array.
    func appendUserPostsDataMapAnnotations() {
        let geoFire = GeoFire(firebaseRef: ref.child("location").child("posts"))
        var seaweedLocation = CLLocation()
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            self.locations = []
            DataService.ds.REF_USERS.child(uid).child("posts").observeSingleEvent(of: .value, with: { snapshot in
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
                                self.locations.append(newPost)
                                print("CHASE: Post key \(newPost.postKey!)")
                                print("CHASE: Post date \(newPost.date!)")
                                print("CHASE: Post UID \(newPost.userId!)")
                                print("CHASE: Post Seaweed Type \(newPost.seaweedType!)")
                                print("CHASE: Post PhotoURL \(newPost.photoURL!)")
                                print("CHASE: Post Session \(newPost.sessionId!)")
                                print("CHASE: Post Latitude \(newPost.lati!)")
                                print("CHASE: Post Longitude \(newPost.longi!)")
                                print("CHASE: POSTS IN ARRAY: \(self.locations.count)")
                            } else {
                                self.userAlertDoMore(alert: "Unable to load data information. Please try again later")
                            }
                            for UserPost in self.locations {
                                let annotation = UserPostAnnotation(title: UserPost.seaweedType, date: UserPost.date, coordinate: CLLocationCoordinate2D(latitude: UserPost.location.coordinate.latitude, longitude: UserPost.location.coordinate.longitude), photoURL: UserPost.photoURL)
                                self.mkMapView.addAnnotation(annotation)
                                print("CHASE: Annotation \(UserPost.postKey!) added")
                            }
                        })
                    })
                }
            })
        }
    }

    ///User alert windows to warn of issue that needs attention before proceeding
    ///
    /// - Parameter alert: String to represent warning that needs to pop up
    func userAlertDoMore (alert: String) {
        let alertController = UIAlertController(title: "Sorry!", message: alert, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        //Alert window settings
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
