//
//  UserPost.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 14/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import Foundation

class UserPost {
    private var _date: String!
    private var _photoURL: String!
    private var _seaweedType: String!
    private var _sessionId: String!
    private var _userId: String!
    private var _postKey: String!
    private var _location: CLLocation!
    private var _lati: String!
    private var _longi: String!
    
    var lati: String! {
        return _lati
    }
    
    var longi: String! {
        return _longi
    }
    
    var date: String! {
        return _date
    }
    
    var photoURL: String! {
        return _photoURL
    }
    
    var seaweedType: String! {
        return _seaweedType
    }
    
    var sessionId: String! {
        return _sessionId
    }
    
    var userId: String! {
        return _userId
    }
    
    var postKey: String! {
        return _postKey
    }
    
    var location: CLLocation {
        return _location
    }
    
    init(postKey: String, date: String, userId: String, seaweedType: String, photoURL: String, sessionId: String, location: CLLocation) {
        self._postKey = postKey
        self._date = date
        self._userId = userId
        self._sessionId = sessionId
        self._photoURL = photoURL
        self._seaweedType = seaweedType
        self._location = location
        self._longi = "\(location.coordinate.longitude)"
        self._lati = "\(location.coordinate.latitude)"
    }
    
}
