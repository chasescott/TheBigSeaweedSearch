//
//  SelectASessionListVC.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 14/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

///Select a session from the list of sessions view controller
class SelectASessionListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var sessions = [Session]()
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        tableView.delegate = self
        tableView.dataSource = self
        
        appendSessionsData()
        self.sessions.reverse()
    }


func numberOfSections(in tableView: UITableView) -> Int {
    return 1
}

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sessions.count
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let session = sessions[indexPath.row]
    if let cell = tableView.dequeueReusableCell(withIdentifier: "SessionListCell", for: indexPath) as? SessionListCell {
        if let img = SelectASessionListVC.imageCache.object(forKey: session.imgURL as NSString) {
            print("CHASE: CELL Configured 1")
            cell.configureCell(session: session, img: img)
        } else {
            print("CHASE: CELL Configured 2")
            cell.configureCell(session: session)
        }
        print("CHASE: CELL RETURNED")
        return cell
    } else {
        print("CHASE: CELL SESSIONCELL() RETURNED")
        return SessionCell()
    } }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let existingSession = sessions[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "sessionListToViewData", sender: existingSession)
    }
    
    ///Pass through session object containing session data to ViewOwnDataVC
    ///
    /// - Parameters:
    ///   - segue: The id of the segue to be initiated
    ///   - sender: The data that is to be sent.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ViewOwnDataVC {
            if let existingSession = sender as? Session {
                destination.currentSession = existingSession
            }
        }
    }

    /// Method that iterates through all sessions Ids stored under users UID node on Firebase.
    ///When session Id has been obtained, code goes to session Id under sessions node on Firebase and obtains all the information necessary to build a Session object.  That object is then appended to an array of Sessions objects which are then used to build a table of cells where each cell represents one session object.  Tableview data is then reloaded.
    func appendSessionsData() {
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            self.sessions = []
            DataService.ds.REF_USERS.child(uid).child("sessions").observeSingleEvent(of: .value, with: { snapshot in
                print(snapshot.childrenCount) // I got the expected number of items
                let enumerator = snapshot.children
                while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                    print("CHASE:  REST KEY - \(rest.key)")
                    let anotherKey: String = rest.key
                    
                    //Then start iterating through sessions node in Firebase to find details of sessions found to be allocated to that specific user as found above 
                DataService.ds.REF_SESSIONS.child(anotherKey).observeSingleEvent(of: .value, with: { (snapshot) in
                        let sessionValue = snapshot.value as? Dictionary<String, AnyObject>
                        let whoWith = sessionValue?["whoWith"] as? String ?? ""
                        let date = sessionValue?["date"] as? String ?? ""
                        let beachGradient = sessionValue?["beachGradient"] as? String ?? ""
                        let beachType = sessionValue?["beachType"] as? String ?? ""
                        let photoURL = sessionValue?["photoURL"] as? String ?? ""
                        let sessionName = sessionValue?["sessionName"] as? String ?? ""
                        let numberOfPosts = sessionValue?["numberOfPosts"] as! Int
                        let newSession = Session(sessionId: anotherKey, imgURL: photoURL, userId: uid, date: date, whoWith: whoWith, beachType: beachType, beachGradient: beachGradient, numberOfPosts: numberOfPosts, sessionName: sessionName)
                        self.sessions.append(newSession)
                        //CHASE: Note to self - You MUST reload table data within this section of code.  My problem was that I was loading my data asynchronously and not calling reloadData once the loading has completed. If this method is called outside of this block it will be executed immediately, before the load is completed.  Therefore execute reload data within this block!
                        self.tableView.reloadData()
                        //Running test code to confirm correct sessions data appended
                        print("CHASE:  Session \(newSession.sessionId) appended")
                        print("CHASE:  Session - Who With: \(newSession.whoWith)")
                        print("CHASE:  Session - Date: \(newSession.date)")
                        print("CHASE:  Session - Beach Gradient: \(newSession.beachGradient)")
                        print("CHASE:  Session - Beach Type: \(newSession.beachType)")
                        print("CHASE:  Session - imgURL: \(newSession.imgURL)")
                        print("CHASE:  Session - User ID: \(newSession.userId)")
                        print("CHASE: Session - Number of Posts: \(newSession.numberOfPosts)")
                        print("CHASE:  Session - Name: \(newSession.sessionName)")
                        print("CHASE: Sessions in ARRAY \(self.sessions.count)")
                    })
                }
            })
        }
    }

    
    @IBAction func backPressed(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
}
