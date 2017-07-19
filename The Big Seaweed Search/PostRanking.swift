//
//  PostRanking.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 18/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import Foundation
import Firebase

class PostRanking {
    private var _userId: String!
    private var _username: String!
    private var _userImgURL: String!
    private var _numberOfPosts: Int!
    private var _rank: UInt!
    
    var userId: String {
        return _userId
    }
    
    var username: String {
        return _username
    }
    
    var userImgURL: String {
        return _userImgURL
    }
    
    var numberOfPosts: Int {
        return _numberOfPosts
    }
    
    var rank: UInt {
        return _rank
    }
    
    init(userId: String, username: String, userImgURL: String, numberOfPosts: Int, rank: UInt) {
        self._userId = userId
        self._username = username
        self._userImgURL = userImgURL
        self._numberOfPosts = numberOfPosts
        self._rank = rank
    }
    
}
