//
//  GroupsMenuVC.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 20/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import UIKit

class GroupsMenuVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func myGroups(_ sender: Any) {
        performSegue(withIdentifier: "toMyGroups", sender: nil)
    }
    
    @IBAction func browseGroups(_ sender: Any) {
        performSegue(withIdentifier: "groupsToBrowseGroups", sender: nil)
    }
    
    @IBAction func setupNewGroup(_ sender: Any) {
        performSegue(withIdentifier: "groupToSetUpGroup", sender: nil)
    }
    
    @IBAction func groupRankingBtn(_ sender: Any) {
        performSegue(withIdentifier: "groupMenuToRankingVC", sender: nil)
    }
    

    @IBAction func backBtn(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func txtBtn(_ sender: Any) {
    }
    
    @IBAction func emailBtn(_ sender: Any) {
    }
    
}
