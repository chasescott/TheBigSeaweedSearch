//
//  AddDataBadgePopUpVC.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 20/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import UIKit

class AddDataBadgePopUpVC: UIViewController {

    @IBOutlet weak var picture: FancyImageView!
    private var _dataCounter: DataCounter?
    private var _currentSession: Session!
    var img: UIImage? = nil
    
    //Getters & setters for Data Counter object
    var dataCounter: DataCounter {
        get {
            return _dataCounter!
        } set {
            _dataCounter = newValue
        }
    }
    
    //getters & setters for Session object
    var currentSession: Session {
        get {
            return _currentSession
        } set {
            _currentSession = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        selectRewardImage()
    }
    
    func selectRewardImage() {
        if dataCounter.isPostType == true {
            let totalCount = dataCounter.count
            if totalCount <= 4 {
                picture.image = #imageLiteral(resourceName: "p0")}
            else if totalCount <= 9 {
                picture.image = #imageLiteral(resourceName: "p1")
            } else if totalCount <= 14 {
                picture.image = #imageLiteral(resourceName: "p2")
            } else if totalCount <= 19 {
                picture.image = #imageLiteral(resourceName: "p3")
            } else if totalCount <= 24 {
                picture.image = #imageLiteral(resourceName: "p4")
            } else {
                picture.image = #imageLiteral(resourceName: "P5")
            }
        }
    }

    @IBAction func okBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    

}
