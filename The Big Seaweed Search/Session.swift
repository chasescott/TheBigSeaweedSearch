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
    private var _sessionId: String!
    
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
    
}
