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
    @IBOutlet var CurrentUserLabel: UILabel!

    var logoImage : UIImageView!
    
    var loginButton : FBSDKLoginButton!
    
    
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
        
    }
    
    override func viewDidLoad() {
        let logoFrame = CGRect(x: 0, y: (self.view.frame.height / 2) - 200, width: self.view.frame.width, height: 400)
        logoImage = UIImageView(frame: logoFrame)
        logoImage.image = UIImage(named: "FlockLogo")
        logoImage.contentMode = UIViewContentMode.ScaleAspectFit
        self.view.addSubview(logoImage)
        var user :PFUser = PFUser.currentUser()!
        var userQuery = PFUser.query()
        userQuery?.getObjectInBackgroundWithId(user.objectId!, block: { (result:PFObject?, error:NSError?) -> Void in
            if (result == nil){
                NSLog("user is nil")
            }
            let res = result as! PFUser
            
            UserCurrentClub = res["LocationName"] as! String
            self.createLocationManager()
            NSLog("ended")
        })
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print(RADIUS)
        
        loginButton = FBSDKLoginButton(frame: CGRect(x: self.view.frame.width - 125, y: 40, width: 120, height: 30))
        loginButton.delegate = self
        self.view.addSubview(loginButton)
    
        //scedule timer
        
        
    }
    
    func createLocationManager() {
        //begin updating gps
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
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
        
        let firstLocation = locations.first as? CLLocation
        
        //println("lat:\(firstLocation?.coordinate.latitude) lon:\(firstLocation?.coordinate.longitude)")
        
        self.getAndUpdateUserLocationDescription(firstLocation!)
        
        
    }
    
    
    func getAndUpdateUserLocationDescription(loc: CLLocation) {
        locationManager.stopUpdatingLocation()
        var lastLocation = UserCurrentClub
        NSLog("Last Location: \(lastLocation)")
        let lat = loc.coordinate.latitude
        let lon = loc.coordinate.longitude
        
        //var currentLocationDescription = "Not In A Club"
        
        var currentClosestClub : String = "Not In A Club"
        var currentClosestDistance = CGFloat(100.0)
        
        for clubLocIndex in 0 ..< GLOBAL_ClubLocations.count {
            if CGFloat(GLOBAL_ClubLocations[clubLocIndex].distanceFromLocation(loc)) < currentClosestDistance {
                currentClosestClub = CLUB_DISPLAY_NAMES[clubLocIndex]
                currentClosestDistance = CGFloat(GLOBAL_ClubLocations[clubLocIndex].distanceFromLocation(loc))
            }
        }
        
        UserCurrentClub = currentClosestClub
        
        NSLog("New Location: \(UserCurrentClub)")
        
        // changed location
        if currentClosestClub != lastLocation {
            locationManager.stopUpdatingLocation()
            NSLog("Changed Location")
            //query for club
            if lastLocation != "Not In A Club" {
                NSLog("Left a club")
                //left a club, subtract from attendence
                var clubQuery : PFQuery = PFQuery(className: "Club")
                clubQuery.whereKey("Club_Name", equalTo: lastLocation)
                clubQuery.findObjectsInBackgroundWithBlock({ (result:[AnyObject]?, error:NSError?) -> Void in
                    if result!.count == 1 {
                        let club : PFObject = result?.first as! PFObject
                        let club_name = club["Club_Name"] as! String
                        NSLog("Subtracting one from \(club_name)")
                        
                        club["Attendance"]! = club["Attendance"] as! Int - 1
                        club.saveInBackground()
                    }
                })
                
            }
            
            //entered a club
            if currentClosestClub != "Not In A Club" {
                NSLog("Entered new club")
                var clubQuery : PFQuery = PFQuery(className: "Club")
                clubQuery.whereKey("Club_Name", equalTo: currentClosestClub)
                clubQuery.findObjectsInBackgroundWithBlock({ (result:[AnyObject]?, error:NSError?) -> Void in
                    if result!.count == 1 {
                        let club : PFObject = result?.first as! PFObject
                        let club_name = club["Club_Name"] as! String
                        NSLog("Adding one to \(club_name)")
                        
                        club["Attendance"]! = club["Attendance"] as! Int + 1
                        club.saveInBackground()
                    }
                })
            }
            
        }
        
        var user : PFUser? = PFUser.currentUser() // problem with updating could be here if the users are not being linked correctly
        if user != nil {
            let user2 : PFUser = user! as PFUser
            user2["LocationName"] = UserCurrentClub
            //user2["history"] = HISTORY_TONIGHT
            user2.saveInBackground()
        }
        NSLog("soy finito")
    }
    
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        self.locationManager.stopUpdatingLocation()
        let del = delegate as! ContainerViewController
        let nav = del.centerNavigationController
        nav.popViewControllerAnimated(true)
        
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



