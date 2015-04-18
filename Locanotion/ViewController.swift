//
//  ViewController.swift
//  Locanotion
//
//  Created by William Bertrand on 3/27/15.
//  Copyright (c) 2015 Locanotion. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, FBSDKLoginButtonDelegate {

    @IBOutlet weak var ViewMapButton: UIButton!
    @IBOutlet weak var ViewFriendsButton: UIButton!
    @IBOutlet weak var ViewClubsButton: UIButton!
    @IBOutlet var CurrentUserLabel: UILabel!
    
    @IBOutlet var logoView: UIImageView!
    @IBOutlet var asd: UIButton!
    
    let locationManager = CLLocationManager()
    
    override func viewWillAppear(animated: Bool) {
        var currentUser = PFUser.currentUser()
        if currentUser != nil {
            CurrentUserLabel.text = currentUser!.username
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
        logoView.image = UIImage(named: "VoleCute")
        logoView.contentMode = .ScaleAspectFit
        logoView.center = self.view.center
        logoView.center.x = ViewClubsButton.center.x
        print("loaded")
        self.createLocationManager()
        print(RADIUS)
        
        let loginButton : FBSDKLoginButton = FBSDKLoginButton(frame: CGRect(x: 15, y: 40, width: 120, height: 30))
        loginButton.delegate = self
        self.view.addSubview(loginButton)
        
    }
    
    func createLocationManager() {
        NSLog("creating loc manager")
        //begin updating gps
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
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
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        print("did update")
        let firstLocation = locations.first as? CLLocation
        NSLog("updating")
        //println("lat:\(firstLocation?.coordinate.latitude) lon:\(firstLocation?.coordinate.longitude)")
        
        self.getAndUpdateUserLocationDescription(firstLocation!)
        
        
    }
    
    func getAndUpdateUserLocationDescription(loc: CLLocation) {
        let lat = loc.coordinate.latitude
        let lon = loc.coordinate.longitude
        var currentLocationDescription = "No location description"
        
        if loc.distanceFromLocation(TERRACE) < RADIUS {
            currentLocationDescription = "In Terrace"
        }
        else if loc.distanceFromLocation(TOWER) < RADIUS {
            currentLocationDescription = "In Tower"
        }
        else if loc.distanceFromLocation(CANNON) < RADIUS {
            currentLocationDescription = "In Cannon"
        }
        else if loc.distanceFromLocation(QUAD) < RADIUS {
            currentLocationDescription = "In Quad"
        }
        else if loc.distanceFromLocation(IVY) < RADIUS {
            currentLocationDescription = "In Ivy"
        }
        else if loc.distanceFromLocation(COTTAGE) < RADIUS {
            currentLocationDescription = "In Cottage"
        }
        else if loc.distanceFromLocation(CAP) < RADIUS {
            currentLocationDescription = "In Cap"
        }
        else if loc.distanceFromLocation(CLOISTER) < RADIUS {
            currentLocationDescription = "In Cloister"
        }
        else if loc.distanceFromLocation(TI) < RADIUS {
            currentLocationDescription = "In TI"
        }
        else if loc.distanceFromLocation(COLONIAL) < RADIUS {
            currentLocationDescription = "In Colonial"
        }
        else if loc.distanceFromLocation(CHARTER) < RADIUS {
            currentLocationDescription = "In Charter"
        }
        else if loc.distanceFromLocation(BOGGLE) < RADIUS {
            currentLocationDescription = "In Boggle"
        }
        else if loc.distanceFromLocation(CS_BUILDING) < RADIUS {
            currentLocationDescription = "In CS Building"
        }
        else if loc.distanceFromLocation(WILCOX_DINING) < RADIUS {
            currentLocationDescription = "In CS Building"
        }
 
        var user : PFUser? = PFUser.currentUser() // problem with updating could be here if the users are not being linked correctly
        NSLog("Saving in background")
        if user != nil {
            let user2 : PFUser = user! as PFUser
            user2["LocationName"] = currentLocationDescription
            user2.saveInBackground()
        }
        
    }
    
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        var cookie : NSHTTPCookie
        var storage : NSHTTPCookieStorage = NSHTTPCookieStorage()
        for cookie in (storage.cookies as! [NSHTTPCookie]) {
            NSLog("deleted cookie")
            storage.deleteCookie(cookie)
        }
        self.locationManager.stopUpdatingLocation()
        self.performSegueWithIdentifier("backToSignInPage", sender: self)
        
        
        
    }
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        //?
    }
    
}

