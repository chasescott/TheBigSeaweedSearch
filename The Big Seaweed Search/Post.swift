//
//  Post.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 11/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import Foundation
import Firebase

class Post {
    private var _postRef: FIRDatabaseReference!
    private var _postKey: String!
    private var _userId: String!
    private var _sessionId: String!
    private var _username: String!
    private var _date: String!
    private var _imageURL: String!
    private var _userphotoURL: String!
    private var _likes: Int!
    private var _seaweedType: String!
    
    var postKey: String! {
        return _postKey
    }
    
    var userId: String! {
        return _userId
    }
    
    var sessionId: String! {
        return _sessionId
    }
    
    var username: String! {
        return _username
    }
    
    var date: String! {
        return _date
    }
    
    var imageURL: String {
        return _imageURL
    }
    
    var userphotoURL: String {
        return _userphotoURL
    }
    
    var likes: Int {
        return _likes
    }
    
    var seaweedType: String! {
        return _seaweedType
    }
    
    init(seaweedType: String, likes:Int, userphotoURL: String, imageURL: String, date: String, username: String, sessionId: String, userId: String, postKey: String){
        self._seaweedType = seaweedType
        self._imageURL = imageURL
        self._likes = likes
        self._userphotoURL = userphotoURL
        self._date = date
        self._username = username
        self._sessionId = sessionId
        self._userId = userId
        self._postKey = postKey
    }
    
    init(postKey: String, username: String, userphotoURL: String, postData: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        self._username = username
        self._userphotoURL = userphotoURL
        
        if let seaweedType = postData["seaweedType"] as? String {
            self._seaweedType = seaweedType
        }
        
        if let imageURL = postData["photoURL"] as? String {
            self._imageURL = imageURL
        }
        
        if let date = postData["date"] as? String {
            self._date = date
        }
        
        if let sessionId = postData["sessionid"] as? String {
            self._sessionId = sessionId
        }
        
        if let userId = postData["userid"] as? String {
            self._userId = userId
        }
        
        if let likes = postData["likes"] as? Int {
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
        _postRef.child("likes").setValue(_likes)
    }

    
}
