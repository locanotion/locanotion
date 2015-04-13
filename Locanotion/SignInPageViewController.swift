//
//  SignInPageViewController.swift
//  Locanotion
//
//  Created by William Bertrand on 3/31/15.
//  Copyright (c) 2015 Locanotion. All rights reserved.
//

import Foundation
import UIKit

class SignInPageViewController : UIViewController, FBSDKLoginButtonDelegate {
    
    override func viewDidLoad() {
        //check acces token to skip log in if they
        if FBSDKAccessToken.currentAccessToken() != nil{
            NSLog("loaded: not nil")
            self.performSegueWithIdentifier("toMainViewSignIn", sender: self)
            let loginButton : FBSDKLoginButton = FBSDKLoginButton()
            loginButton.readPermissions = ["public_profile", "email", "user_friends"]
            self.view.addSubview(loginButton)
            loginButton.center.x = self.view.center.x
            loginButton.center.y = self.view.center.y + (self.view.frame.height / 2) - 75
            loginButton.delegate = self
        }
        else {
            
            let loginButton : FBSDKLoginButton = FBSDKLoginButton()
            loginButton.readPermissions = ["public_profile", "email", "user_friends"]
            self.view.addSubview(loginButton)
            loginButton.center.x = self.view.center.x
            loginButton.center.y = self.view.center.y + (self.view.frame.height / 2) - 75
            loginButton.delegate = self
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if error != nil {
            //process the error
            NSLog("Error")
        }
        else if result.isCancelled{
            //handle cancellation
        }
            
        else {
            //query parse to see if there is a user already with this facebook id
            let newUserQuery : PFQuery = PFUser.query()!
            newUserQuery.whereKey("facebook_ID", equalTo:result.token.userID)
            
            newUserQuery.findObjectsInBackgroundWithBlock({ (objectArray:[AnyObject]?, error:NSError?) -> Void in
                if error != nil {
                    //error with query
                }
                else {
                    let objects = objectArray!
                    if objects.count == 0 {
                        
                        var request : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
                        
                        request.startWithCompletionHandler { (connection:FBSDKGraphRequestConnection!, result: AnyObject!, error:NSError!) -> Void in
                            if error == nil {
                                let resultDict : NSDictionary  = result as! NSDictionary
                                let fullName : String = resultDict.objectForKey("name") as! String
                                //email not always available
                                let email : String! = resultDict.objectForKey("email") as! String
                                //var gender : String! = resultDict.objectForKey("gender") as String
                                let fbID : String = resultDict.objectForKey("id") as! String
                                
                                //create the PFUser
                                var newUser : PFUser = PFUser()
                                if email != nil {
                                    newUser.username = email
                                }
                                newUser["Full_Name"] = fullName
                                newUser.email = email
                                newUser["facebook_ID"] = fbID
                                newUser.password = "tempPassword"
                                
                                newUser.signUpInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                                    if success {
                                        let alertView = UIAlertView()
                                        alertView.title = "Signed up as new user!"
                                        alertView.addButtonWithTitle("Ok")
                                        alertView.show()
                                    }
                                })
                                
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    let permissions = ["public_profile", "email", "user_friends"]
                                    PFFacebookUtils.linkUserInBackground(PFUser.currentUser()!, withReadPermissions: permissions, block: { (success : Bool, error : NSError?) -> Void in
                                        if success {
                                           NSLog("linked new user with new pfuser")
                                        }
                                    })
                                })
                                
                            }
                            
                            
                        }
                        
                    }//end of objects.count == 0
                    else if objects.count == 1{
                        //link with existing pfUser
                        let userWithID : PFUser = objects[0] as! PFUser
                        
                        let permissions = ["public_profile", "email", "user_friends"]
                        PFFacebookUtils.linkUserInBackground(userWithID, withReadPermissions: permissions, block: { (success : Bool, error : NSError?) -> Void in
                            if success {
                                let alertView = UIAlertView()
                                alertView.title = "Signed in as existing user!"
                                alertView.addButtonWithTitle("Ok")
                                alertView.show()
                            }
                        })
                    }
                }
                
            })
            self.performSegueWithIdentifier("toMainViewSignIn", sender: self)
        }
        
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        NSLog("User Logged Out")
    }
    
    
    
}
