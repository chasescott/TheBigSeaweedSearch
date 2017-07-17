//
//  Comment.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 17/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import Foundation
import Firebase

class Comment {
    private var _commentKey: String!
    private var _postId: String!
    private var _commentAuthorId: String!
    private var _commentAuthorUsername: String!
    private var _date: String!
    private var _comment: String!
    
    var commentKey: String {
        return _commentKey
    }
    
    var postId: String {
        return _postId
    }
    
    var commentAuthorId: String {
        return _commentAuthorId
    }
    
    var date: String {
        return _date
    }
    
    var comment: String {
        return _comment
    }
    
    var commentAuthorUsername: String {
        return _commentAuthorUsername
    }
    
    init(commentKey: String, postId: String, commentAuthorId: String, date: String, comment: String, commentAuthorUsername: String) {
        self._commentKey = commentKey
        self._postId = postId
        self._commentAuthorId = commentAuthorId
        self._date = date
        self._comment = comment
        self._commentAuthorUsername = commentAuthorUsername
    }
    
    init(commentKey: String, commentData: Dictionary<String, AnyObject>) {
        self._commentKey = commentKey
        
        if let postId = commentData["postid"] as? String {
            self._postId = postId
        }
        
        if let commentAuthorId = commentData["commentAuthorId"] as? String {
            self._commentAuthorId = commentAuthorId
        }
        
        if let date = commentData["date"] as? String {
            self._date = date
        }
        
        if let comment = commentData["comment"] as? String {
            self._comment = comment
        }
        
        if let commentUsername = commentData["commentAuthorUsername"] as? String {
            self._commentAuthorUsername = commentUsername
        }
    }
    
}
