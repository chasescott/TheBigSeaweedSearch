//
//  ViewBadgesVC.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 19/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

///View badges view controller class
class ViewBadgesVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var CollectionViewPosts: UICollectionView!
    
    @IBOutlet weak var CollectionViewSessions: UICollectionView!
    
    var posts = [UIImage]()
    var sessions = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CollectionViewPosts.delegate = self
        CollectionViewPosts.dataSource = self
        CollectionViewSessions.delegate = self
        CollectionViewSessions.dataSource = self
//        self.view.addSubview(CollectionViewPosts)
//        self.view.addSubview(CollectionViewSessions)
        appendPostsBadges()
        appendSessionsBadges()
    }
    
    ///Method to check number of user posts on Firebase and then display the relevant badges in an array for UICollectionView
    func appendPostsBadges() {
    if let uid = FIRAuth.auth()?.currentUser?.uid {
        DataService.ds.REF_USERS.child(uid).observeSingleEvent(of: .value, with: { snapshot in
            let userInfo = snapshot.value as? Dictionary<String, AnyObject>
            let numberOfPosts = userInfo?["numberOfPosts"] as! Int
            print("CHASE: Number of posts is \(numberOfPosts)")
            if numberOfPosts == 0 {
                self.posts = []
                print("CHASE: Number of posts in Array \(self.posts.count)")
                self.CollectionViewPosts.reloadData()
            } else if numberOfPosts <= 4 {
                self.posts = []
                self.posts = [#imageLiteral(resourceName: "pb0")]
                print("CHASE: Number of posts in Array \(self.posts.count)")
                self.CollectionViewPosts.reloadData()
            } else if numberOfPosts <= 9 {
                self.posts = []
                self.posts = [#imageLiteral(resourceName: "pb0"), #imageLiteral(resourceName: "pb1")]
                print("CHASE: Number of posts in Array \(self.posts.count)")
                self.CollectionViewPosts.reloadData()
            } else if numberOfPosts <= 14 {
                self.posts = []
                self.posts = [#imageLiteral(resourceName: "pb0"), #imageLiteral(resourceName: "pb1"), #imageLiteral(resourceName: "pb2")]
                print("CHASE: Number of posts in Array \(self.posts.count)")
                self.CollectionViewPosts.reloadData()
            } else if numberOfPosts <= 19 {
                self.posts = []
                self.posts = [#imageLiteral(resourceName: "pb0"), #imageLiteral(resourceName: "pb1"), #imageLiteral(resourceName: "pb2"), #imageLiteral(resourceName: "pb3")]
                print("CHASE: Number of posts in Array \(self.posts.count)")
                self.CollectionViewPosts.reloadData()
            } else if numberOfPosts <= 24 {
                self.posts = []
                self.posts = [#imageLiteral(resourceName: "pb0"), #imageLiteral(resourceName: "pb1"), #imageLiteral(resourceName: "pb2"), #imageLiteral(resourceName: "pb3"), #imageLiteral(resourceName: "pb4")]
                print("CHASE: Number of posts in Array \(self.posts.count)")
                self.CollectionViewPosts.reloadData()
            } else {
                self.posts = []
                self.posts = [#imageLiteral(resourceName: "pb0"), #imageLiteral(resourceName: "pb1"), #imageLiteral(resourceName: "pb2"), #imageLiteral(resourceName: "pb3"), #imageLiteral(resourceName: "pb4"), #imageLiteral(resourceName: "pb5")]
                print("CHASE: Number of posts in Array \(self.posts.count)")
                self.CollectionViewPosts.reloadData()
            }
        }
        )
        }
    }
    
    ///Method to check number of user posts on Firebase and then display the relevant badges in an array for UICollectionView
    func appendSessionsBadges() {
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            DataService.ds.REF_USERS.child(uid).observeSingleEvent(of: .value, with: { snapshot in
                let userInfo = snapshot.value as? Dictionary<String, AnyObject>
                let numberOfSessions = userInfo?["numberOfSessions"] as! Int
                print("CHASE: Number of sessions is \(numberOfSessions)")
                if numberOfSessions == 0 {
                    self.sessions = []
                    self.CollectionViewSessions.reloadData()
                } else if numberOfSessions <= 4 {
                    self.sessions = []
                    self.sessions = [#imageLiteral(resourceName: "sb0")]
                    print("CHASE: Number of sessions in Array \(self.sessions.count)")
                    self.CollectionViewSessions.reloadData()
                } else if numberOfSessions <= 9 {
                    self.sessions = []
                    self.sessions = [#imageLiteral(resourceName: "sb0"), #imageLiteral(resourceName: "sb1")]
                    print("CHASE: Number of sessions in Array \(self.sessions.count)")
                    self.CollectionViewSessions.reloadData()
                } else if numberOfSessions <= 14 {
                    self.sessions = []
                    self.sessions = [#imageLiteral(resourceName: "sb0"), #imageLiteral(resourceName: "sb1"), #imageLiteral(resourceName: "sb2")]
                    print("CHASE: Number of sessions in Array \(self.sessions.count)")
                    self.CollectionViewSessions.reloadData()
                } else if numberOfSessions <= 19 {
                    self.sessions = []
                    self.sessions = [#imageLiteral(resourceName: "sb0"), #imageLiteral(resourceName: "sb1"), #imageLiteral(resourceName: "sb2"), #imageLiteral(resourceName: "sb3")]
                    print("CHASE: Number of sessions in Array \(self.sessions.count)")
                    self.CollectionViewSessions.reloadData()
                } else if numberOfSessions <= 24 {
                    self.sessions = []
                    self.sessions = [#imageLiteral(resourceName: "sb0"), #imageLiteral(resourceName: "sb1"), #imageLiteral(resourceName: "sb2"), #imageLiteral(resourceName: "sb3"), #imageLiteral(resourceName: "sb4")]
                    print("CHASE: Number of sessions in Array \(self.sessions.count)")
                    self.CollectionViewSessions.reloadData()
                } else {
                    self.sessions = []
                    self.sessions = [#imageLiteral(resourceName: "sb0"), #imageLiteral(resourceName: "sb1"), #imageLiteral(resourceName: "sb2"), #imageLiteral(resourceName: "sb3"), #imageLiteral(resourceName: "sb4"), #imageLiteral(resourceName: "sb5")]
                    print("CHASE: Number of sessions in Array \(self.sessions.count)")
                    self.CollectionViewSessions.reloadData()
                }
            })
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.CollectionViewSessions {
            if let cell = CollectionViewSessions.dequeueReusableCell(withReuseIdentifier: "SessionCell", for: indexPath) as? BadgesSessionsCell
            {
                cell.picture.image = nil
                cell.configureCell(img: sessions[indexPath.row])
                print("CHASE: Session Cell Returned")
                return cell
            }
            return BadgesSessionsCell()
        }
        else if collectionView == self.CollectionViewPosts {
            if let cell = CollectionViewPosts.dequeueReusableCell(withReuseIdentifier: "PostCell", for: indexPath) as? BadgesPostsCell
            {
                cell.picture.image = nil
                cell.configureCell(img: posts[indexPath.row])
                print("CHASE: Post Cell Returned")
                return cell
            }
        }
        return BadgesPostsCell()
        }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.CollectionViewSessions {
            return sessions.count
        }
            return posts.count
        }

    @IBAction func backBtn(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
}

