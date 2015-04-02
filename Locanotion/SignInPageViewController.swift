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
        NSLog("loaded")
        
        //check acces token to skip log in if they
        if FBSDKAccessToken.currentAccessToken() != nil{
             NSLog("loaded: not nil")
            self.performSegueWithIdentifier("toMainViewSignIn", sender: self)
        }
        else {
            
            let loginButton : FBSDKLoginButton = FBSDKLoginButton()
            loginButton.readPermissions = ["public_profile", "email", "user_friends"]
            self.view.addSubview(loginButton)
           // var FBLoginConstraint = NSLayoutConstraint(item: loginButton, attribute: NSLayoutAttribute.Bottom, relatedBy: <#NSLayoutRelation#>, toItem: <#AnyObject?#>, attribute: <#NSLayoutAttribute#>, multiplier: <#CGFloat#>, constant: <#CGFloat#>)
            loginButton.center = self.view.center
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
            self.performSegueWithIdentifier("toMainViewSignIn", sender: self)
        }
        
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        NSLog("User Logged Out")
    }
   
    
   
}
