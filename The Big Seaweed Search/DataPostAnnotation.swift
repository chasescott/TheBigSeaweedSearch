//
//  DataPostAnnotation.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 18/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import Foundation
import MapKit
import Firebase

class DataPostAnnotation: NSObject, MKAnnotation {
    let postKey: String
    let seaweedType: String
    let date: String
    let coordinate: CLLocationCoordinate2D
    let photoURL: String
    let username: String
    let userImgURL: String
    let userId: String
    let sessionId : String
    let likes: Int
    private var _postRef: FIRDatabaseReference!
    
    init(postKey: String, seaweedType: String, date: String, coordinate: CLLocationCoordinate2D, photoURL: String, username: String, userImgURL: String, userId: String, sessionId: String, likes: Int) {
        self.postKey = postKey
        self.seaweedType = seaweedType
        self.date = date
        self.coordinate = coordinate
        self.photoURL = photoURL
        self.username = username
        self.userImgURL = userImgURL
        self.userId = userId
        self.sessionId = sessionId
        self.likes = likes
        super.init()
    }
    
    var subtitle: String? {
        return date
    }
    
    var title: String? {
        return seaweedType
    }
    
}
