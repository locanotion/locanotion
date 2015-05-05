//
//  ViewController.swift
//  Locanotion
//
//  Created by William Bertrand on 3/27/15.
//  Copyright (c) 2015 Locanotion. All rights reserved.
//

import UIKit
import CoreLocation

//Global
var UserCurrentClub : String!

class ViewController: UIViewController, CLLocationManagerDelegate, FBSDKLoginButtonDelegate {
    @IBOutlet var CurrentUserLabel: UILabel!
    
    //used for the history
    var lastClubName : String!
    var label : UILabel!
    
    
    @IBOutlet var logoView: UIImageView!
    @IBOutlet var asd: UIButton!
    
    let locationManager = CLLocationManager()
    
    //Properties for side-panel menu
    var delegate: CenterViewControllerDelegate?
    
    @IBAction func menuTapped(sender: AnyObject) {
        delegate?.toggleLeftPanel?()
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        var currentUser = PFUser.currentUser()
        if currentUser != nil {
            CurrentUserLabel.text = currentUser!.username
        }
        else {
            CurrentUserLabel.text = "No User"
        }
        if UserCurrentClub != nil {
            label.text = "You are at \(UserCurrentClub)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.createLocationManager()
        print(RADIUS)
        
        let loginButton : FBSDKLoginButton = FBSDKLoginButton(frame: CGRect(x: self.view.frame.width - 125, y: 40, width: 120, height: 30))
        loginButton.delegate = self
        self.view.addSubview(loginButton)
        
        let logoFrame = CGRect(x: 0, y: (self.view.frame.height / 2) - 200, width: self.view.frame.width, height: 400)
        let logoImage = UIImageView(frame: logoFrame)
        logoImage.image = UIImage(named: "FlockLogo")
        logoImage.contentMode = UIViewContentMode.ScaleAspectFit
        self.view.addSubview(logoImage)
        
        
        var labelFrame : CGRect = CGRect(x: logoFrame.origin.x, y: logoFrame.origin.y + logoFrame.height + 10, width: logoFrame.width, height: 50)
        label = UILabel(frame: labelFrame)
        if UserCurrentClub != nil {
            label.text = "You are at \(UserCurrentClub)"
        }
        else {
            label.text = "No Club Location Info"
        }
        self.view.addSubview(label)
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
        var currentLocationDescription = "Not In A Club"
        
        var currentClosestClub : String = "Not In A Club"
        var currentClosestDistance = CGFloat(100.0)
        
        for clubLocIndex in 0 ..< GLOBAL_ClubLocations.count {
            NSLog("LOC")
            NSLog("\(CLUB_DISPLAY_NAMES[clubLocIndex])  \(CGFloat(GLOBAL_ClubLocations[clubLocIndex].distanceFromLocation(loc)))")
            if CGFloat(GLOBAL_ClubLocations[clubLocIndex].distanceFromLocation(loc)) < currentClosestDistance {
                currentClosestClub = CLUB_DISPLAY_NAMES[clubLocIndex]
                currentClosestDistance = CGFloat(GLOBAL_ClubLocations[clubLocIndex].distanceFromLocation(loc))
            }
        }
        
        UserCurrentClub = currentClosestClub
        currentLocationDescription = currentClosestClub
        if currentClosestClub != lastClubName && currentClosestClub != "Not In A Club" {
            HISTORY_TONIGHT.append(currentClosestClub)
        }
        
        var user : PFUser? = PFUser.currentUser() // problem with updating could be here if the users are not being linked correctly
       
        if user != nil {
            NSLog("Saving user")
            let user2 : PFUser = user! as PFUser
            NSLog(user2["Full_Name"] as! String)
            user2["LocationName"] = currentLocationDescription
            user2["history"] = HISTORY_TONIGHT
            user2.saveInBackground()
        }
        
    }
    
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        self.locationManager.stopUpdatingLocation()
        self.performSegueWithIdentifier("backToSignInPage", sender: self)
        
    }
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        //?
    }
    
}

//Mark sidepanelViewControllerDelegate methods

extension ViewController: SidePanelViewControllerDelegate {
    
    func navItemSelected(item: NavItem) {
        delegate?.collapseSidePanels?()
        
        let del = delegate as! ContainerViewController
        let nav = del.centerNavigationController
        NSLog("VIEWVIEWVIEW")
        if item.title == "View Map"{
            del.leftViewController?.delegate = del.mapPageViewController
            nav.pushViewController(del.mapPageViewController, animated: true)
            
        }
        else if item.title == "View Friends"{
            del.leftViewController?.delegate = del.friendsViewController
            nav.pushViewController(del.friendsViewController, animated: true)
        }
        else if item.title == "View Clubs"{
            del.leftViewController?.delegate = del.clubsViewController
            nav.pushViewController(del.clubsViewController, animated: true)
        }
    }

}



