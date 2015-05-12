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
          
            NSLog("ended")
        })
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
        
        loginButton = FBSDKLoginButton(frame: CGRect(x: self.view.frame.width - 125, y: 40, width: 120, height: 30))
        loginButton.delegate = self
        self.view.addSubview(loginButton)
        self.createLocationManager()
        //scedule timer
        //NSTimer.scheduledTimerWithTimeInterval(15, target: self, selector: "updateLocationManual", userInfo: nil, repeats: true)
        
    }
    
    func createLocationManager() {
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
    
    func updateLocationManual(){
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        NSLog("Location Updated")
        let firstLocation = locations.first as? CLLocation
        if firstLocation?.horizontalAccuracy < 30 {
            self.getAndUpdateUserLocationDescription(firstLocation!)
        }
        NSLog("Updating")
    }
    
    func getAndUpdateUserLocationDescription(loc: CLLocation) {
        
        //locationManager.stopUpdatingLocation()
        var lastLocation = UserCurrentClub
        NSLog("Last Location: \(lastLocation)")
        let lat = loc.coordinate.latitude
        let lon = loc.coordinate.longitude
        
        //var currentLocationDescription = "Migrating"
        
        var currentClosestClub : String = "Migrating"
        var currentClosestDistance = CGFloat(30)
        
        for clubLocIndex in 0 ..< GLOBAL_ClubLocations.count {
            if CGFloat(GLOBAL_ClubLocations[clubLocIndex].distanceFromLocation(loc)) < currentClosestDistance {
                currentClosestClub = CLUB_NAMES[clubLocIndex]
                currentClosestDistance = CGFloat(GLOBAL_ClubLocations[clubLocIndex].distanceFromLocation(loc))
            }
        }
        
        UserCurrentClub = currentClosestClub
        
        NSLog("New Location: \(UserCurrentClub)")
        
        var user : PFUser? = PFUser.currentUser() // problem with updating could be here if the users are not being linked correctly
        if user != nil {
            NSLog("Saving to Parse")
            let user2 : PFUser = user! as PFUser
            user2["LocationName"] = UserCurrentClub
            //user2["history"] = HISTORY_TONIGHT
            user2.saveInBackground()
        }


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



