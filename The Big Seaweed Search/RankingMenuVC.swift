//
//  RankingMenuVC.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 18/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import UIKit

class RankingMenuVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func postsTapped(_ sender: Any) {
        performSegue(withIdentifier: "rankingMenuToPostsLeaderboardVC", sender: nil)
    }
    
    @IBAction func sessionsTapped(_ sender: Any) {
        performSegue(withIdentifier: "rankingToSessionsVC", sender: nil)
    }
    
    @IBAction func viewBadges(_ sender: Any) {
        performSegue(withIdentifier: "rankingMenuToBadges", sender: nil)
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }

}
