//
//  UserProfile.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 08/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import Foundation
import Firebase

class UserProfile {
    private var _userID: String!
    private var _imageURL: String!
    private var _username: String!
    private var _location: String!
    
    var imageURL: String {
        return _imageURL
    }
    
    var username: String {
        return _username
    }
    
    var location: String {
        return _location
    }
    
    var userID: String {
        return _userID
    }
    
    init(imageURL: String, username: String, location: String, userID: String) {
        self._username = username
        self._imageURL = imageURL
        self._location = location
        self._userID = userID
    }
    
//    init(userKey: String, profileData: Dictionary<String, AnyObject>) {
//        self._userID = userKey
//        if let username = profileData["username"] as? AnyObject {
//            self._username = username as! String
//        }
//        if let imageURL = profileData["photoURL"] as? AnyObject {
//            self._imageURL = imageURL as! String
//        }
//        if let location = profileData["location"] as? AnyObject {
//            self._location = location as! String
//        }
//    }
    
}
