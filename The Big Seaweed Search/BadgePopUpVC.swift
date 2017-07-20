//
//  BadgePopUpVC.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 20/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class BadgePopUpVC: UIViewController {

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
        navigationItem.hidesBackButton = true
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        selectRewardImage()
    }
    
    func selectRewardImage () {
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
        } else if dataCounter.isPostType == false {
            let totalCount = dataCounter.count
            if totalCount == 0 {
                picture.image = nil
            } else if totalCount <= 4 {
                picture.image = #imageLiteral(resourceName: "s0")
            } else if totalCount <= 9 {
                picture.image = #imageLiteral(resourceName: "s1")
            } else if totalCount <= 14 {
                picture.image = #imageLiteral(resourceName: "s2")
            } else if totalCount <= 19 {
                picture.image = #imageLiteral(resourceName: "s3")
            } else if totalCount <= 24 {
                picture.image = #imageLiteral(resourceName: "s4")
            } else {
                picture.image = #imageLiteral(resourceName: "s5")
            }
        }
    }

    @IBAction func cancelBtn(_ sender: Any) {
        userAlertSuccess(alert: "Your session has now been activated.  Please continue to collect data")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? AddDataVC {
            destinationVC.currentSession = currentSession
        }
    }
    
    //User alert to advise of success and perform segue to next screen
    func userAlertSuccess (alert: String) {
        let alertController = UIAlertController(title: "Success!", message: alert, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler:
            {
                action in self.performSegue(withIdentifier: "badgePopUpToAddDataVC", sender: self)
        }
        ))
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert + 1;
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alertController, animated: true, completion: nil)
    }

    
}
