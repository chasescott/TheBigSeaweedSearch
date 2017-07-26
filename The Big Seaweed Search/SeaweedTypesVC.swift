//
//  SeaweedTypesVC.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 13/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import UIKit

///Pop over view showing images of types of seaweed for the user to choose from
class SeaweedTypesVC: UIViewController {

    @IBOutlet weak var picture: UIImageView!
    
    //initialise image array for scroll view images
    var index = 0
    var imageIndex = 0
    let maxImages = 11
//    var myArray:[String] = ["0.png","1.png","2.png","3.png","4.png","5.png","6.png","7.png","8.png","9.png","10.png","11.png"]
    var imageList:[String] = ["0.png","1.png","2.png","3.png","4.png","5.png","6.png","7.png","8.png","9.png","10.png","11.png"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        picture.image = UIImage(named:"0.png")
    }
    
    /// Swipe right through images
    ///
    /// - Parameter sender: Swipe gesture
    @IBAction func swiping(_ sender: Any) {
        //swiping right
        print("User swiped right")
        // decrease index first
        imageIndex -= 1
        
        // check if index is in range
        if imageIndex < 0 {
            
            imageIndex = maxImages
            
        }
        
        picture.image = UIImage(named: imageList[imageIndex])
    }
    
    /// Swipe left through images
    ///
    /// - Parameter sender: Swipe gesture
    @IBAction func swipeLeft(_ sender: Any) {
        print("User swiped Left")
        
        // increase index first
        
        imageIndex += 1
        
        // check if index is in range
        
        if imageIndex > maxImages {
            
            imageIndex = 0
            
        }
        
        picture.image = UIImage(named: imageList[imageIndex])
    }
    
    
    @IBAction func dontBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
