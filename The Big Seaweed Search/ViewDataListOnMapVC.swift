//
//  ViewDataListOnMapVC.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 17/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import SwiftKeychainWrapper

class ViewDataListOnMapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapKit: MKMapView!
    let regionRadius: CLLocationDistance = 500
    //GPS location storage variables
    let locationManager = CLLocationManager()
    var userLocation = CLLocation()
    
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var img: UIImage? = nil
    
    private var _currentDataPost: DataPost!
    
    var currentDataPost: DataPost {
        get {
            return _currentDataPost
        } set {
            _currentDataPost = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        mapKit.delegate = self
        centerMapOnLocation(location: currentDataPost.location)
        
        let annotation = UserPostAnnotation(title: currentDataPost.seaweedType, date: currentDataPost.date, coordinate: CLLocationCoordinate2D(latitude: currentDataPost.location.coordinate.latitude, longitude:currentDataPost.location.coordinate.longitude), photoURL: currentDataPost.photoURL)
        
        mapKit.addAnnotation(annotation)
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
        userLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            let locValue:CLLocationCoordinate2D = manager.location!.coordinate
            userLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
            locationManager.stopUpdatingLocation()
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapKit.setRegion(coordinateRegion, animated: true)
    }
    
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//      let annotation = view.annotation as! UserPostAnnotation
        performSegue(withIdentifier: "viewImgOverMapOnList", sender: self.currentDataPost)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ViewAllDataPopOverVC {
            if let currentDataPost = sender as? DataPost {
                destination.currentDataPost = currentDataPost
            }
        }
    }

    
    @IBAction func backBtn(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
}
