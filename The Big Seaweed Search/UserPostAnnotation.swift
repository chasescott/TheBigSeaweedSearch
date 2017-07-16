//
//  UserPostAnnotation.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 16/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import Foundation
import MapKit

class UserPostAnnotation: NSObject, MKAnnotation {
    let title: String?
    let date: String
    let coordinate: CLLocationCoordinate2D
    let photoURL: String
    
    init(title: String, date: String, coordinate: CLLocationCoordinate2D, photoURL: String) {
        self.title = title
        self.date = date
        self.coordinate = coordinate
        self.photoURL = photoURL
        
        super.init()
    }
    
    var subtitle: String? {
        return date
    }
}
