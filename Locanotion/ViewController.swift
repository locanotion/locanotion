//
//  ViewController.swift
//  Locanotion
//
//  Created by William Bertrand on 3/27/15.
//  Copyright (c) 2015 Locanotion. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var ViewMapButton: UIButton!
    @IBOutlet weak var ViewFriendsButton: UIButton!
    @IBOutlet weak var ViewClubsButton: UIButton!
    @IBOutlet var CurrentUserLabel: UILabel!
    
    @IBOutlet var asd: UIButton!
    override func viewWillAppear(animated: Bool) {
        var currentUser = PFUser.currentUser()
        if currentUser != nil {
            CurrentUserLabel.text = currentUser.username
        }
        else {
            CurrentUserLabel.text = "No User"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        ViewMapButton.layer.cornerRadius = 3
        ViewFriendsButton.layer.cornerRadius = 3
        ViewClubsButton.layer.cornerRadius = 3
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    @IBAction func SignOutPressed(sender: AnyObject) {
        PFUser.logOut()
        var currentUser = PFUser.currentUser()
        if currentUser != nil {
            let alert = UIAlertView()
            alert.title = "Alert"
            alert.message = "Unable to logout"
            alert.addButtonWithTitle("Ok")
            alert.show()
        }
        else {
            self.performSegueWithIdentifier("backToLogIn", sender: self)
        }
    }
}

