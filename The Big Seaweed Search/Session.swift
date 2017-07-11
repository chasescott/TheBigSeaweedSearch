//
//  Session.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 11/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import Foundation
import Firebase

class Session {
    private var _imgURL: String!
    private var _userId: String!
    private var _date: String!
    private var _whoWith: String!
    private var _beachType: String!
    private var _beachGradient: String!
    private var _sessionId: String! //i.e. session key
    private var _sessionRef: FIRDatabaseReference!
    
    var imgURL: String {
        return _imgURL
    }
    
    var userId: String {
        return _userId
    }
    
    var date: String! {
        return _date
    }
    
    var whoWith: String! {
        return _whoWith
    }
    
    var beachType: String! {
        return _beachType
    }
    
    var beachGradient: String! {
        return _beachGradient
    }
    
    var sessionId: String! {
        return _sessionId
    }
    
    init(sessionId: String, imgURL: String, userId: String, date: String, whoWith: String, beachType: String, beachGradient: String)
    {
        self._sessionId = sessionId
        self._imgURL = imgURL
        self._userId = userId
        self._date = date
        self._whoWith = whoWith
        self._beachType = beachType
        self._beachGradient = beachGradient
    }
    
    init(sessionId: String, sessionData:Dictionary<String, AnyObject>) {
        self._sessionId = sessionId
        
        if let imgURL = sessionData["photoURL"] as? String {
            self._imgURL = imgURL
        }
        
        if let userId = sessionData["userid"] as? String {
            self._userId = userId
        }
        
        if let date = sessionData["date"] as? String {
            self._date = date
        }
        
        if let whoWith = sessionData["whoWith"] as? String {
            self._whoWith = whoWith
        }
        
        if let beachType = sessionData["beachType"] as? String {
            self._beachType = beachType
        }
        
        if let beachGradient = sessionData["beachGradient"] as? String {
            self._beachGradient = beachGradient
        }
        _sessionRef = DataService.ds.REF_SESSIONS.child(_sessionId)
    }
}
