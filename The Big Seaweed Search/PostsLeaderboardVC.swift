//
//  PostsLeaderboardVC.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 18/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//
import Firebase
import SwiftKeychainWrapper
import UIKit

class PostsLeaderboardVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var positionLbl: UILabel!
    @IBOutlet weak var postsLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var postrankings = [PostRanking]()
    var userPostArray = [PostRanking]()
    
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    let uid = FIRAuth.auth()?.currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
         view.backgroundColor = UIColor.white
        tableView.delegate = self
        tableView.dataSource = self
        appendPostRankingData()
        self.postrankings.reverse()
        DataService.ds.REF_LEADERBOARD.child(uid!).observeSingleEvent(of: .value, with: { snapshot in
            let userValue = snapshot.value as? Dictionary<String, AnyObject>
            let numberOfPosts = userValue?["numberOfPosts"] as! Int
            self.postsLbl.text = "\(numberOfPosts)"
        })
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postrankings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let postranking = postrankings[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostsLeaderboardCell", for: indexPath) as? PostsLeaderboardCell {
            if let img = PostsLeaderboardVC.imageCache.object(forKey: postranking.userImgURL as NSString) {
                cell.configureCell(postranking: postranking, img: img)
            } else {
                cell.configureCell(postranking: postranking)
            }
            return cell
        } else {
            return PostsLeaderboardCell()
        }
    }
    
    func appendPostRankingData() {
        if (FIRAuth.auth()?.currentUser?.uid) != nil {
            self.postrankings = []
            DataService.ds.REF_LEADERBOARD.queryOrdered(byChild: "numberOfPosts").observeSingleEvent(of: .value, with: { snapshot in
                print(snapshot.childrenCount)
                var totalCount = snapshot.childrenCount
                let enumerator = snapshot.children
                while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                print("CHASE:  REST KEY - \(rest.key)")
                let anotherKey: String = rest.key
                    
                DataService.ds.REF_LEADERBOARD.child(anotherKey).observeSingleEvent(of: .value, with: { (snapshot) in
                let userValue = snapshot.value as? Dictionary<String, AnyObject>
                let username = userValue?["username"] as? String ?? ""
                let photoURL = userValue?["photoURL"] as? String ?? ""
                let numberOfPosts = userValue?["numberOfPosts"] as! Int
                let newRanking = PostRanking(userId: anotherKey, username: username, userImgURL: photoURL, numberOfPosts: numberOfPosts, rank: totalCount)
                totalCount = totalCount - 1
                self.postrankings.insert(newRanking, at: 0)
                self.tableView.reloadData()
                    for PostRanking in self.postrankings {
                        if PostRanking.userId == self.uid {
                            self.positionLbl.text = "\(PostRanking.rank)"
                        }
                    }
          })
    }
    })
    }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
}
