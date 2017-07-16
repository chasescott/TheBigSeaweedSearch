//
//  ViewAllDataVC.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 16/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class ViewAllDataVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var dataposts = [DataPost]()
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    //Geofire variables
    var geoFire: GeoFire!
    let ref = FIRDatabase.database().reference()
    var img: UIImage? = nil

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        tableView.delegate = self
        tableView.dataSource = self
        appendData()
        self.dataposts.reverse()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataposts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let datapost = dataposts[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath) as? DataPostCell {
            if let img = ViewAllDataVC.imageCache.object(forKey: datapost.photoURL as NSString) {
                cell.configureCell(datapost: datapost, img: img) }
            else {
                cell.configureCell(datapost: datapost)
            }
            return cell
        } else {
        return DataPostCell()
    }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let exisitingData = dataposts[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "viewAllDataListToSingleItem", sender: exisitingData)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ViewAllDataOneVC {
            if let existingData = sender as? DataPost {
                destination.currentData = existingData
            }
        }
    }
    
    func appendData() {
        let geoFire = GeoFire(firebaseRef: ref.child("location").child("posts"))
        var seaweedLocation = CLLocation()
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            self.dataposts = []
//            DataService.ds.REF_POSTS.queryLimited(toFirst: 100).observeSingleEvent(of: .value, with: { snapshot in
        DataService.ds.REF_POSTS.observeSingleEvent(of: .value, with: { snapshot in
                print (snapshot.childrenCount) //get the expected number of post items
                let enumerator = snapshot.children //start iterating through post items
                while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                    print("CHASE: Post KEY - \(rest.key)")
                    let anotherKey: String = rest.key
                    DataService.ds.REF_POSTS.child(anotherKey).observeSingleEvent(of: .value, with: { (snapshot) in
                    //Start iterating through posts node on Firebase
                    let postValue = snapshot.value as? Dictionary<String, AnyObject>
                    let date = postValue?["date"] as? String ?? ""
                    let seaweedType = postValue?["seaweedType"] as? String ?? ""
                    let photoURL = postValue?["photoURL"] as? String ?? ""
                    let sessionId = postValue?["sessionid"] as? String ?? ""
                    let userId = postValue?["userid"] as? String ?? ""
                    let numberOfLikes = postValue?["numberOfLikes"] as! Int
                    //Go to GeoFire to obtain post co-ordinates and build/append userpost object within this area of code
                    geoFire!.getLocationForKey(anotherKey, withCallback: { (location, error) in
                        if let location = location {
                            seaweedLocation = location
                            print("CHASE: Geofire Location stored")
                            print("Seaweed Lat: \(seaweedLocation.coordinate.latitude)")
                            print("Seaweed Lon: \(seaweedLocation.coordinate.longitude)")
                    //get user photo url and username from leaderboard firebase nodes
                            DataService.ds.REF_LEADERBOARD.child(userId).observe(.value, with: { (snapshot) in
                                let userValue = snapshot.value as? Dictionary<String, AnyObject>
                                let username = userValue?["username"] as? String ?? ""
                                let userphotoURL = userValue?["photoURL"] as? String ?? ""
                            //plug in all variables into datapost object
                                let newPost = DataPost(postKey: anotherKey, date: date, userId: userId, seaweedType: seaweedType, photoURL: photoURL, sessionId: sessionId, location: seaweedLocation, username: username, userimgURL: userphotoURL, likes: numberOfLikes)
                                //SORT THE LIKES OUT!!!
                                print("CHASE: New Data post appended: \(newPost.postKey!)")
                                self.dataposts.append(newPost)
                                self.tableView.reloadData()
                            })
        
    }
    })
    })
    }
    })
    }
    }
    
    @IBAction func backBtn(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
}
