//
//  ViewAllOnMapVC.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 18/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import SwiftKeychainWrapper

///View all data on one map view controller
class ViewAllOnMapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let regionRadius: CLLocationDistance = 5000
    //GPS location storage variables
    let locationManager = CLLocationManager()
    var userLocation = CLLocation()
    //Image cache variables
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var img: UIImage? = nil
    //Locations array for map
    var locations = [DataPost]()
    //Geofire variables
    var geoFire: GeoFire!
    let ref = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        locationManager.delegate = self
        mapView.delegate = self
        let locValue:CLLocationCoordinate2D = locationManager.location!.coordinate
        let initialLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        centerMapOnLocation(location: initialLocation)
        appendMapAnnotations()
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
        mapView.setRegion(coordinateRegion, animated: true)
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
    


    /// Annotations added to the map.  Run at viewDidLoad() and looks to Firebase to run GeoFire query and locate the nearest post objects around the users location and then returns the top X values.  The post and user data is pulled from Firebase and attached to the annotation objects array.
    func appendMapAnnotations() {
        let geoFire = GeoFire(firebaseRef: ref.child("location").child("posts"))
        var seaweedLocation = CLLocation()
        if (FIRAuth.auth()?.currentUser?.uid) != nil {
            self.locations = []
        DataService.ds.REF_POSTS.observeSingleEvent(of: .value, with: { snapshot in
            print (snapshot.childrenCount) //get the expected number of post items
            let enumerator = snapshot.children //start iterating through post items
            while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                print("CHASE: Post KEY - \(rest.key)")
                let postKey: String = rest.key
                //Start iterating through posts node on Firebase to find details of sessions found to be allocated ot that specific user as found above
                DataService.ds.REF_POSTS.child(postKey).observeSingleEvent(of: .value, with: { (snapshot) in
                let postValue = snapshot.value as? Dictionary<String, AnyObject>
                let date = postValue?["date"] as? String ?? ""
                let seaweedType = postValue?["seaweedType"] as? String ?? ""
                let photoURL = postValue?["photoURL"] as? String ?? ""
                let sessionId = postValue?["sessionid"] as? String ?? ""
                let userId = postValue?["userid"] as? String ?? ""
                let numberOfLikes = postValue?["numberOfLikes"] as! Int
            
            DataService.ds.REF_LEADERBOARD.child(userId).observeSingleEvent(of: .value, with: { snapshot in
                let userValue = snapshot.value as? Dictionary<String, AnyObject>
                let username = userValue?["username"] as? String ?? ""
                let userImgURL = userValue?["photoURL"] as? String ?? ""
                geoFire!.getLocationForKey(postKey, withCallback: { (location, error) in
                    if let location = location {
                        seaweedLocation = location
                        print("CHASE: Geofire Location stored")
                        print("Seaweed Lat: \(seaweedLocation.coordinate.latitude)")
                        print("Seaweed Lon: \(seaweedLocation.coordinate.longitude)")
                let newPost = DataPost(postKey: postKey, date: date, userId: userId, seaweedType: seaweedType, photoURL: photoURL, sessionId: sessionId, location: seaweedLocation, username: username, userimgURL: userImgURL, likes: numberOfLikes)
                self.locations.append(newPost)
                    }
                    for DataPost in self.locations {
                        let annotation = DataPostAnnotation(postKey: DataPost.postKey, seaweedType: DataPost.seaweedType, date: DataPost.date, coordinate: CLLocationCoordinate2D(latitude: DataPost.location.coordinate.latitude, longitude: DataPost.location.coordinate.longitude), photoURL: DataPost.photoURL, username: DataPost.username, userImgURL: DataPost.userimgURL, userId: DataPost.userId, sessionId: DataPost.sessionId, likes: DataPost.likes)
                        self.mapView.addAnnotation(annotation)
                        print("CHASE: Annotation \(DataPost.postKey!) added")
                    }
                })
            })
        })
        }
     })
    }
   }
    
    
    /// MapView annotation pin tapped action
    ///
    /// - Parameters:
    ///   - mapView: map view object
    ///   - view: the view used in the pin annotation
    ///   - control: the type of control object
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let annotation = view.annotation as! DataPostAnnotation
        let postKey = annotation.postKey
        let date = annotation.date
        let userId = annotation.userId
        let seaweedType = annotation.seaweedType
        let photoURL = annotation.photoURL
        let sessionId = annotation.sessionId
        let location = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude) //revisit this
        let username = annotation.username
        let userimgURL = annotation.userImgURL
        let likes = annotation.likes
        let dataPost = DataPost(postKey: postKey, date: date, userId: userId, seaweedType: seaweedType, photoURL: photoURL, sessionId: sessionId, location: location, username: username, userimgURL: userimgURL, likes: likes)
        performSegue(withIdentifier: "viewAllDataMapVCtoViewDataInformationVC", sender: dataPost)
    }
    
    ///Pass through session object containing session data to add data VC
    ///
    /// - Parameters:
    ///   - segue: The id of the segue to be initiated
    ///   - sender: The data that is to be sent.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ViewAllDataOneVC {
            if let currentData = sender as? DataPost {
                destination.currentData = currentData
            }
        }
    }
    
    
    
    @IBAction func backBtn(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
}
