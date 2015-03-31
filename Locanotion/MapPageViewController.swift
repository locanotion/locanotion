//
//  MapPageViewController.swift
//  Locanotion
//
//  Created by William Bertrand on 3/31/15.
//  Copyright (c) 2015 Locanotion. All rights reserved.
//

import Foundation

class MapPageViewController : UIViewController {
    let swipeRec = UISwipeGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        swipeRec.addTarget(self, action: "swipeHandler:")
    }
    
    func swipeHadler(recognizer:UIGestureRecognizer) {
        //go back to the friends page
        self.performSegueWithIdentifier("backToFriendsView", sender: self)
    }
}
