//
//  DataPost.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 16/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import Firebase
import Foundation

class DataPost {
    private var _date: String!
    private var _photoURL: String!
    private var _seaweedType: String!
    private var _sessionId: String!
    private var _userId: String!
    private var _postKey: String!
    private var _location: CLLocation!
    private var _username: String!
    private var _userimgURL: String!
    private var _likes: Int!
    private var _postRef: FIRDatabaseReference!
    
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

    var username: String {
        return _username
    }
    
    var userimgURL: String {
        return _userimgURL
    }
    
    var likes: Int {
        return _likes
    }
    
    init(postKey: String, date: String, userId: String, seaweedType: String, photoURL: String, sessionId: String, location: CLLocation, username: String, userimgURL: String, likes: Int) {
        self._postKey = postKey
        self._date = date
        self._userId = userId
        self._sessionId = sessionId
        self._photoURL = photoURL
        self._seaweedType = seaweedType
        self._location = location
        self._username = username
        self._userimgURL = userimgURL
        self._likes = likes
    }
    
    init(postKey: String, location: CLLocation, username: String, userimgURL: String,  postData: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        self._location = location
        self._username = username
        self._userimgURL = userimgURL
        
        if let date = postData["date"] as? String {
            self._date = date
        }
        
        if let userId = postData["userid"] as? String {
            self._userId = userId
        }
        
        if let sessionId = postData["sessionid"] as? String {
            self._sessionId = sessionId
        }
        
        if let photoURL = postData["photoURL"] as? String {
            self._photoURL = photoURL
        }
        
        if let seaweedType = postData["seaweedType"] as? String {
            self._seaweedType = seaweedType
        }
        
        if let likes = postData["numberOfLikes"] as? Int {
            self._likes = likes
        }
       _postRef = DataService.ds.REF_POSTS.child(_postKey)
    }

    func adjustLikes(addLike: Bool) {
        if addLike {
            _likes = _likes + 1
        } else {
            _likes = _likes - 1
        }
        DataService.ds.REF_POSTS.child(_postKey).child("numberOfLikes").setValue(_likes)
        //_postRef.child("numberOfLikes").setValue(_likes)
    }
    
}
