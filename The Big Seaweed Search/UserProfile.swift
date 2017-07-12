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
    private var _numberOfPosts: Int! //
    private var _userRef: FIRDatabaseReference! //
    
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
    
    var numberOfPosts: Int {
        return _numberOfPosts
    }
    
    init(imageURL: String, username: String, location: String, userID: String) {
        self._username = username
        self._imageURL = imageURL
        self._location = location
        self._userID = userID
        self._numberOfPosts = 0 //
    }
    
    init(userKey: String, profileData: Dictionary<String, AnyObject>) {
        self._userID = userKey
        if let username = profileData["username"] as? String {
            self._username = username
        }
        if let imageURL = profileData["photoURL"] as? String {
            self._imageURL = imageURL
        }
        if let location = profileData["location"] as? String {
            self._location = location
        }
        if let numberOfPosts = profileData["numberOfPosts"] as? Int {
            self._numberOfPosts = numberOfPosts
        }
        _userRef = DataService.ds.REF_USERS.child(_userID)
    }
    
    func adjustNumberOfPosts(addPost:Bool){
        if addPost {
            _numberOfPosts = _numberOfPosts + 1
        } else {
            _numberOfPosts = _numberOfPosts - 1
        }
        _userRef.child("numberOfPosts").setValue(_numberOfPosts)
    }

    
}
