//
//  ViewAllDataOneVC.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 16/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import MapKit

class ViewAllDataOneVC: UIViewController, UITextViewDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var likesImg: UIImageView!
    @IBOutlet weak var picture: FancyImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var usernameLbl: UILabel!
    
    var comments = [Comment]()
    
    private var _currentData: DataPost?
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var img: UIImage? = nil
    //Date constants
    let date = NSDate()
    let formatter = DateFormatter()
    var dateAsString: String!
    var dateString: String!
    //Other variables
    var commentId: String!
    //Firebase Refs
    var likesRef: FIRDatabaseReference!
    
    var currentData: DataPost {
        get {
            return _currentData!
        } set {
            _currentData = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableView delegates
        tableView.delegate = self
        tableView.dataSource = self
        //Append comments data
        appendCommentsData()
        //Add gesture recogniser to likes image
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likesImg.addGestureRecognizer(tap)
        likesImg.isUserInteractionEnabled = true
        // set UI and date variables
        let myColor = UIColor.darkGray
        likesRef = DataService.ds.REF_USER_CURRENT.child("likes").child(currentData.postKey)
        commentTextView.delegate = self
        commentTextView.layer.borderWidth = 1.0
        commentTextView.layer.borderColor = myColor.cgColor
        formatter.dateFormat = "dd/MM/yyyy"
        dateAsString = formatter.string(from: date as Date)
        dateString = "\(formatter.string(from: date as Date))"
        usernameLbl.text = currentData.username
        likesLbl.text = "Number of Likes: \(currentData.likes)"
        titleLbl.text = currentData.seaweedType
        if img != nil {
            self.picture.image = img
            self.profileImg.image = img
        } else {
            let ref = FIRStorage.storage().reference(forURL: currentData.photoURL)
            let ref2 = FIRStorage.storage().reference(forURL: currentData.userimgURL)
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                } else {
                    if let imgData = data {
                        if let img = UIImage(data: imgData)
                        {
                            self.picture.image = img
                            ViewAllDataOneVC.imageCache.setObject(img, forKey: self.currentData.photoURL as NSString)
                        }
                    }
                }
            })
            ref2.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                } else {
                    if let imgData = data {
                        if let img = UIImage(data: imgData)
                        {
                            self.profileImg.image = img
                            ViewAllDataOneVC.imageCache.setObject(img, forKey: self.currentData.userimgURL as NSString)
                            self.profileImg.image = img
                        }
                    }
                }
            })
        }
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likesImg.image = UIImage(named: "empty-heart")
            } else {
                self.likesImg.image = UIImage(named: "filled-heart")
            }
            
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment = comments[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentCell {
            cell.configureCell(comment: comment)
        } else {
            return CommentCell()
        }
        return CommentCell()
        }
    
    func likeTapped(sender: UITapGestureRecognizer){
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likesImg.image = UIImage(named: "filled-heart")
                self.currentData.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
                DataService.ds.REF_POSTS.child(self.currentData.postKey!).observeSingleEvent(of: .value, with: { (snapshot) in
                            if let postDict = snapshot.value as? Dictionary<String, AnyObject> {
                                let numberOfLikes = postDict["numberOfLikes"] as! Int
                                print("CHASE:  \((self.currentData.postKey!)) post noted.  Number of likes: \(numberOfLikes)")
                                self.likesLbl.text = "Number of Likes: \(numberOfLikes)"
                            }})
            } else {
                self.likesImg.image = UIImage(named: "empty-heart")
                self.currentData.adjustLikes(addLike: false)
                self.likesRef.removeValue()
                DataService.ds.REF_POSTS.child(self.currentData.postKey!).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let postDict = snapshot.value as? Dictionary<String, AnyObject> {
                        let numberOfLikes = postDict["numberOfLikes"] as! Int
                        print("CHASE:  \((self.currentData.postKey!)) post noted.  Number of likes: \(numberOfLikes)")
                        self.likesLbl.text = "Number of Likes: \(numberOfLikes)"
                    }})
            }
        })
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        commentTextView.text = ""
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            commentTextView.resignFirstResponder()
            return false
        }
        return true
    }
    
    @IBAction func pictureTapped(_ sender: Any) {
        performSegue(withIdentifier: "infoToAllDataPopOverVC", sender: currentData)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ViewAllDataPopOverVC {
            if let currentData = sender as? DataPost {
                destination.currentDataPost = currentData
            }
        } else if let destination2 = segue.destination as? ViewDataListOnMapVC {
            if let currentData = sender as? DataPost {
                destination2.currentDataPost = currentData
            }
        }
    }
    
    @IBAction func addCommentPressed(_ sender: Any) {
        if let uid = FIRAuth.auth()?.currentUser?.uid {
        guard let comment = commentTextView.text, comment != "", comment != "(Insert comment here)" else {
            userAlertDoMore(alert: "Please enter some text into the comment box to comment...")
            return
        }
            //Get users username from Firebase and store
            DataService.ds.REF_LEADERBOARD.child(uid).observe(.value, with: { (snapshot) in //took out observe single event... of:
                let userValue = snapshot.value as? Dictionary<String, AnyObject>
                let userName = userValue?["username"] as? String ?? ""
            //create comment object ready for firebase upload
        let commentObject: Dictionary<String, AnyObject> = [
        "comment": self.commentTextView.text! as AnyObject,
        "postid": self.currentData.postKey as AnyObject,
        "date": self.dateString as AnyObject,
        "commentAuthorId": uid as AnyObject,
        "commentAuthorUsername": userName as AnyObject
        ]
            //1. Upload comment to firebase
            let firebasePost = DataService.ds.REF_COMMENTS.childByAutoId()
            firebasePost.setValue(commentObject)
            //2.  takes the firebasePost auto ID key and stores in firebaseKey commentId key
            let firebaseKey = firebasePost.key
            self.commentId = firebaseKey
            
            //3.  stores comment key in user section of firebase under 'comments'
            FIRDatabase.database().reference().child("users/\(uid)/comments").child(firebaseKey).setValue(true)
            
            //4.  stores comment key under 'posts' section of firebase under post ID
            FIRDatabase.database().reference().child("posts/\(self.currentData.postKey!)/comments").child(firebaseKey).setValue(true)
            
            //5.  Reset text field
            self.commentTextView.text = ""
            self.appendCommentsData()
            self.userAlertSuccess(alert: "Your comment has been added.")
        })
    }
    }
    
    func appendCommentsData() {
        if (FIRAuth.auth()?.currentUser?.uid) != nil {
            //Listener for new comment posts
            DataService.ds.REF_POSTS.child(currentData.postKey!).child("comments").observeSingleEvent(of: .value, with: { (snapshot) in
                self.comments = [] //clears the posts array each time that it is loaded to prevent duplicate posts.
                if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for snap in snapshot {
                            let key = snap.key
                            DataService.ds.REF_COMMENTS.child(key).observe(.value, with: { (snapshot) in
                            let commentData = snapshot.value as? Dictionary<String, AnyObject>
                                let comment = Comment(commentKey: key, commentData: commentData!)
                                print("Appending: \(comment.commentKey)")
                                self.comments.append(comment)
                                self.tableView.reloadData()
                                self.comments.reverse()
                                print("Comments Array Count: \(self.comments.count)")
                            })
                    }
                }
            })
        }
    }
    
    @IBAction func viewMapPressed(_ sender: Any) {
        performSegue(withIdentifier: "listToViewOnMap", sender: currentData)
    }
    
    //User alert to advise of success
    func userAlertSuccess (alert: String) {
        let alertController = UIAlertController(title: "Success!", message: alert, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil
        ))
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert + 1;
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    //User alert windows to warn of issue that needs attention before proceeding
    func userAlertDoMore (alert: String) {
        let alertController = UIAlertController(title: "Wait a minute...", message: alert, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert + 1;
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    @IBOutlet weak var backBtn: UIBarButtonItem!
    @IBAction func backBtnPressed(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
}
