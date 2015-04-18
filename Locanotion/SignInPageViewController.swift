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
            
            var id: String = "Uninit"
            //get facebook id
            var request : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
            
            request.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result: AnyObject!, error : NSError!) -> Void in
                if error == nil {
                    print(result)
                    var resultDict : NSDictionary = result as! NSDictionary
                    id = resultDict.objectForKey("id") as! String
                    println("the id from FB is : \(id)")
                    
                    
                    let newUserQuery : PFQuery = PFUser.query()!
                    newUserQuery.whereKey("facebook_ID", equalTo:id)
                    
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
                                                
                                                let permissions = ["public_profile", "email", "user_friends"]
                                                PFFacebookUtils.linkUserInBackground(PFUser.currentUser()!, withReadPermissions: permissions, block: { (success : Bool, error : NSError?) -> Void in
                                                    if success {
                                                        NSLog("linked new user with new pfuser")
                                                        self.performSegueWithIdentifier("toMainViewSignIn", sender: self)
                                                    }
                                                })
                                                
                                            }
                                        })
                                        
                                    }
                                    
                                }
                                
                            }//end of objects.count == 0
                            else if objects.count == 1 {
                                //log in this user
                                var  curUser : PFUser = objects[0] as! PFUser
                                let username = curUser["username"] as! String
                                let password = "temppassword"
                                
                                PFUser.logInWithUsernameInBackground(username, password: password, block: { (user:PFUser?, error:NSError?) -> Void in
                                    if user != nil {
                                        NSLog("logged in \(username)")
                                        self.performSegueWithIdentifier("toMainViewSignIn", sender: self)
                                    }
                                    
                                })
                            }
                            
                            else {
                                
                            }
                        }
                        
                    })
                    
                }
                
            }
            NSLog("id from fb outside of comp: %s", id)
            
            
            //query parse to see if there is a user already with this facebook id
            
        }
        
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        NSLog("User Logged Out")
    }
    
    
    
}
