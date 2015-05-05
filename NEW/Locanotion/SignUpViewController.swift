//
//  SignUpViewController.swift
//  Locanotion
//
//  Created by Nicholas Pai on 3/29/15.
//  Copyright (c) 2015 Locanotion. All rights reserved.
//

import Foundation
import UIKit

class SignUpViewController: UIViewController {
    @IBOutlet var nameField: UITextField!
    @IBOutlet var locField: UITextField!
    @IBOutlet var SignUpButton: UIButton!
    @IBOutlet var LogInButton: UIButton!
    
    @IBOutlet var errorLabel: UILabel!
    
    override func viewDidLoad() {
        SignUpButton.layer.cornerRadius = 3
        LogInButton.layer.cornerRadius = 3
    }
    
    @IBAction func logIn() {
        
        if nameField.text.isEmpty || locField.text.isEmpty {
            let alert = UIAlertView()
            alert.title = "No Text"
            alert.message = "Please Enter Text In The Box"
            alert.addButtonWithTitle("Ok")
            alert.show()
            return
        }
        let username : String = nameField.text as String
        PFUser.logInWithUsernameInBackground(username, password: "password") {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.performSegueWithIdentifier("goToMainView", sender: self)
                }
            }
            else {
                //log in failed
                NSLog("Not Logged in")
                let alert = UIAlertView()
                alert.title = "Error"
                alert.message = "Invalid Login"
                alert.addButtonWithTitle("Ok")
                alert.show()
                
            }
        }

    }
    
    @IBAction func signUp() {
        
        if nameField.text.isEmpty || locField.text.isEmpty {
            let alert = UIAlertView()
            alert.title = "No Text"
            alert.message = "Please Enter Text In The Box"
            alert.addButtonWithTitle("Ok")
            alert.show()
            return
        }

        var user = PFUser()
        user.username = nameField.text
        user.password = "password"
        user.email = nameField.text + "@princeton.edu"
        
        user["LocationName"] = locField.text
        
        user.signUpInBackgroundWithBlock({ (succeeded: Bool, error: NSError?) -> Void in
            if error != nil {
                let alert = UIAlertView()
                alert.title = "Error"
                alert.message = "Already a user with that name"
                alert.addButtonWithTitle("Ok")
                alert.show()
            }
            else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.performSegueWithIdentifier("goToMainView", sender: self)
                }
            }
        })

    }

}

