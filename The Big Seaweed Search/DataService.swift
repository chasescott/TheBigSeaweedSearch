//
//  DataService.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 05/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import Foundation
import Firebase
import SwiftKeychainWrapper

let DB_BASE = FIRDatabase.database().reference()
let STORAGE_BASE = FIRStorage.storage().reference()

class DataService {
    
    static let ds = DataService()
    
    //DB references
    private var _REF_BASE = DB_BASE
    private var _REF_POSTS = DB_BASE.child("posts")
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_LEADERBOARD = DB_BASE.child("leaderboard")
    private var _REF_COMMENTS = DB_BASE.child("comments")
    private var _REF_USERS_PROFILE = DB_BASE.child("users").child("profile")
    private var _REF_SESSIONS = DB_BASE.child("sessions")
    
    //GeoFire DB References
    private var _REF_GEOFIRE_POSTS = DB_BASE.child("location").child("posts")
    
    private var _REF_GEOFIRE_SESSIONS = DB_BASE.child("location").child("sessions")
    
    //Storage references
    private var _REF_POST_IMAGES = STORAGE_BASE.child("post-pics")
    private var _REF_PROFILE_IMAGES = STORAGE_BASE.child("profile-pics")
    private var _REF_SESSION_IMAGE = STORAGE_BASE.child("session-pics")
    
    //the following public variables used as getters for the private variables above prevent anyone else referencing the private variables.
    
    var REF_BASE: FIRDatabaseReference {
        return _REF_BASE
    }
    
    var REF_COMMENTS: FIRDatabaseReference {
        return _REF_COMMENTS
    }
    
    var REF_POSTS: FIRDatabaseReference {
        return _REF_POSTS
    }
    
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    
    var REF_LEADERBOARD: FIRDatabaseReference {
        return _REF_LEADERBOARD
    }
    
    var REF_USERS_PROFILE: FIRDatabaseReference {
        return _REF_USERS_PROFILE
    }
    
    var REF_SESSIONS: FIRDatabaseReference {
        return _REF_SESSIONS
    }
    
    var REF_USER_CURRENT: FIRDatabaseReference {
        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        let user = REF_USERS.child(uid!)
        return user
    }
    
    var REF_GEOFIRE_POSTS: FIRDatabaseReference {
        return _REF_GEOFIRE_POSTS
    }
    
    var REF_GEOFIRE_SESSIONS: FIRDatabaseReference {
        return _REF_GEOFIRE_SESSIONS
    }
    
    var REF_POST_IMAGES: FIRStorageReference {
        return _REF_POST_IMAGES
    }
    
    var REF_PROFILE_IMAGES: FIRStorageReference {
        return _REF_PROFILE_IMAGES
    }
    
    var REF_SESSION_IMAGES: FIRStorageReference {
        return _REF_PROFILE_IMAGES
    }
    
    func createFirebaseDataSession(sessionid: String, userData: Dictionary<String,String>) {
        REF_SESSIONS.child(sessionid).updateChildValues(userData)
    }
    
    func createFirebaseDBUser(uid: String, userData: Dictionary<String, String>) {
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
    func createFirebaseDBUserProfile(uid: String, profileData: Dictionary<String, AnyObject>) {
        REF_USERS.child(uid).child("profile").updateChildValues(profileData)
    }
    
    func updateFirebaseDBUserProfile(uid: String, profileData: Dictionary<String, AnyObject>) {
        REF_USERS.child(uid).child("profile").updateChildValues(profileData)
    }
    
    func SetUpFirebaseNumberOfPosts(uid:String) {        REF_USERS.child(uid).child("numberOfPosts").setValue(0)
    }
    
    func SetUpFirebaseNumberOfSessions(uid:String) {
        REF_USERS.child(uid).child("numberOfSessions").setValue(0)
    }
    
    func setUpUserOnLeaderboard(uid: String, userData: Dictionary<String, AnyObject>) {
        REF_LEADERBOARD.child(uid).updateChildValues(userData)
    }
}
