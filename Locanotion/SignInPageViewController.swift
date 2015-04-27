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
    
    
    @IBOutlet var previewScrollView: UIScrollView!
    let previewImages : Array<String> = ["previewFriends","FindFriends","viewClubs","previewNotifications"]
    
    
    override func viewDidLoad() {
        let loginButton : FBSDKLoginButton = FBSDKLoginButton()
        //check acces token to skip log in if they haven't lost access 
        if FBSDKAccessToken.currentAccessToken() != nil{
            NSLog("loaded: not nil")
            self.performSegueWithIdentifier("toMainViewSignIn", sender: self)
            loginButton.readPermissions = ["public_profile", "email", "user_friends"]
            self.view.addSubview(loginButton)
            loginButton.center.x = self.view.center.x
            loginButton.center.y = self.view.center.y + (self.view.frame.height / 2) - 75
            loginButton.delegate = self
        }
        else {
            
            
            loginButton.readPermissions = ["public_profile", "email", "user_friends"]
            self.view.addSubview(loginButton)
            loginButton.center.x = self.view.center.x
            loginButton.center.y = self.view.center.y + (self.view.frame.height / 2) - 75
            loginButton.delegate = self
        }
        var getStarted : UIImageView = UIImageView()
        getStarted.image = UIImage(named: "GetStarted")
        getStarted.frame = CGRect(x: loginButton.frame.origin.x, y:loginButton.frame.origin.y - loginButton.frame.height - 5, width:loginButton.frame.width, height: loginButton.frame.height)
        getStarted.contentMode=UIViewContentMode.ScaleAspectFit
        self.view.addSubview(getStarted)
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
                                                
                                                self.createFriendshipRelations()
                                                
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
                                        self.createFriendshipRelations()
                                        self.performSegueWithIdentifier("toMainViewSignIn", sender: self)
                                    }
                                    
                                })
                            }
                            
                            else {}
                        }
                        
                    })
                    
                }
            }
        }
    }
    
    func createFriendshipRelations() {
        //get all PFUsers with facebook Id's
        var idArray : Array<String> = Array()
        var request : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/friends", parameters: nil)
        
        request.startWithCompletionHandler({ (connection:FBSDKGraphRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
            if error == nil {
                var resultDict : NSDictionary = result as! NSDictionary
                var data : NSArray = resultDict.objectForKey("data") as! NSArray
                
                for value in data {
                    let valueDict : NSDictionary = value as! NSDictionary
                    let id = valueDict.objectForKey("id") as! String
                    idArray.append(id)
                }
                
                //now make a friendship activity for each friend found
                for id in idArray {
                    
                    var friendQuery : PFQuery = PFUser.query()!
                    friendQuery.whereKey("facebook_ID", equalTo: id)
                    
                    friendQuery.findObjectsInBackgroundWithBlock({ (result:[AnyObject]?, error:NSError?) -> Void in
                        let resultUser = result?.first as! PFUser
                        //create friend activity
                        var friendShip : PFObject = PFObject(className: "Activity")
                        friendShip["Type"] = "Friend"
                        friendShip["From_User"] = PFUser.currentUser()
                        friendShip["To_User"] = resultUser
                        friendShip.saveInBackground()
                    })
                }
            }
        })
    }
    
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        NSLog("User Logged Out")
    }
    
    override func viewDidLayoutSubviews() {
        var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        frame.size = CGSizeMake(self.previewScrollView.bounds.size.width, previewScrollView.frame.height / 2)
        
        //set up preview images
        for index in 0..<previewImages.count {
            frame.origin.x = previewScrollView.frame.size.width * CGFloat(index)
            print("frame.x: \(frame.origin.x)")
            print("width: \(frame.size.width)")
            frame.origin.y = previewScrollView.frame.size.height / 4
            var subView = UIImageView(frame: frame)
            subView.image = UIImage(named: previewImages[index])
            subView.contentMode = UIViewContentMode.ScaleAspectFit
            previewScrollView.pagingEnabled = true
            previewScrollView.addSubview(subView)
            
        }
        
        self.previewScrollView.contentSize = CGSizeMake(self.previewScrollView.frame.size.width * CGFloat(previewImages.count), self.previewScrollView.frame.size.height)
    }
    
    
    
}
