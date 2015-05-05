//
//  MapPageViewController.swift
//  Locanotion
//
//  Created by William Bertrand on 3/31/15.
//  Copyright (c) 2015 Locanotion. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

class MapPageViewController : UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    let swipeRec = UISwipeGestureRecognizer()
    let locationManager = CLLocationManager()
    var userLocationAnnotation : CustomPointAnnotation = CustomPointAnnotation()
    var friendIDs :Array<String> = Array()
    //@IBOutlet var scrollView : UIScrollView!
    @IBOutlet var mapView: MKMapView!
    
    //hash map for attendences
    //var attendenceArray : Array(String, Int) = Array()
    
    ///Array of tuples:(string,int) to hold club, num people
    var clubInfoArray = [String: Int]()
    //another array to hold just friend attendence counts
    var friendsInfoArray = [String: Int]()
    
    
    //Properties for side-panel menu
    var delegate: CenterViewControllerDelegate?
    
    var menuButton : UIButton!
    var userLocation : CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for club in CLUB_NAMES {
            friendsInfoArray[club] = 0
            clubInfoArray[club] = 0
        }
        print(friendsInfoArray)
        
        
        menuButton = UIButton(frame:CGRect(x: 10, y: 25, width: 40, height: 30))
        menuButton.setBackgroundImage(UIImage(named: "MenuIcon"), forState: UIControlState.Normal)
        menuButton.addTarget(self, action: "menuTapped", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(menuButton)
        
        //implement swipes?
        swipeRec.addTarget(self, action: "swipeHandler:")
        mapView.delegate = self
        
        //set content size and stuff for the scroll view
        //set up annotation
        userLocationAnnotation.imageName = "UserLocationIcon"
        //set up map view
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        

        let region = MKCoordinateRegionMakeWithDistance(
            CLLocationCoordinate2D(latitude: 40.348544, longitude: -74.652330), 280, 280)
        
        mapView.setRegion(region, animated: true)
        
        mapView.zoomEnabled = false
        
        //mapView.addAnnotation(userLocationAnnotation)
        //self.getFacebookFriendsLocations()
        
        self.getAllClubInfo()
        self.getFriendsClubInfo()
    }
    
    func menuTapped() {
        delegate?.toggleLeftPanel?()
    }

    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation is CustomPointAnnotation {
            let reuseID = "test"
            var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID)
            if anView == nil {
                anView = MKAnnotationView(annotation: annotation,reuseIdentifier: reuseID)
                anView.canShowCallout = true
            }
            else {
                anView.annotation = annotation
            }
            
            let cpa = annotation as! CustomPointAnnotation
            anView.image = UIImage(named:cpa.imageName)
            let frame = anView.frame
            let textFrame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height / 3)
            let textLabel = UILabel(frame: textFrame)
            textLabel.textAlignment = .Center
            textLabel.text = cpa.name
            textLabel.font = UIFont(name: "Avenir Next", size: 11)
            anView.addSubview(textLabel)
            let FriendFrame = CGRect(x: 0, y: textFrame.height, width: frame.width, height: frame.height / 3)
            let friendLabel = UILabel(frame: FriendFrame)
            let intA : Int = self.friendsInfoArray[cpa.name]!
            friendLabel.text = String(intA) + " Friends"
            friendLabel.textAlignment = .Center
            friendLabel.font = UIFont(name: "Avenir Next", size: 11)
            anView.addSubview(friendLabel)
            //add total attendence label
            let totalFrame = CGRect(x: 0, y: textFrame.height + FriendFrame.height, width: frame.width, height: frame.height / 3)
            let totalLabel = UILabel(frame: totalFrame)
            totalLabel.textAlignment = .Center
            let intB : Int = self.clubInfoArray[cpa.name]!
            totalLabel.text = String(intB) + "Total People"
            totalLabel.font = UIFont(name: "Avenir Next", size: 11)
            anView.addSubview(totalLabel)
            return anView
            
        }
        
        return nil
    }
    func setUpAllClubViews() {
        for club in 0 ..< GLOBAL_ClubLocations.count {
            let cpa = CustomPointAnnotation()
            cpa.coordinate = GLOBAL_ClubLocations[club].coordinate
            cpa.name = CLUB_NAMES[club]
            cpa.imageName = "annotation"
            cpa.friendAttendence = friendsInfoArray[CLUB_NAMES[club]]
            cpa.totalAttendence = clubInfoArray[CLUB_NAMES[club]]
            NSLog(cpa.name)
            NSLog("long:\(cpa.coordinate.longitude)lat:\(cpa.coordinate.latitude)")
            mapView.addAnnotation(cpa)
        }
    }

    
    func getFacebookFriendsLocations() {
        var idArray : Array<String> = Array()
        NSLog("called method")
        var request : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/friends", parameters: nil)
        
        request.startWithCompletionHandler { (connection:FBSDKGraphRequestConnection!, result: AnyObject!, error:NSError!) -> Void in
            NSLog("In handler")
            if error == nil {
                print(result)
                var resultDict : NSDictionary = result as! NSDictionary
                
                print("data we get from result: ")
                var data : NSArray = resultDict.objectForKey("data") as! NSArray
                
                let valueDict : NSDictionary = data[0] as! NSDictionary
                let id = valueDict.objectForKey("id") as! String
                idArray.append(id)
                self.friendIDs.append(id)
                print(id)
            }
        }
        
    }
    
    func swipeHadler(recognizer:UIGestureRecognizer) {
        //go back to the friends page
        self.performSegueWithIdentifier("backToFriendsView", sender: self)
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        print("updating location")
        var location :CLLocation = locations[locations.count - 1] as! CLLocation
        userLocation = location
    }
    func backToMainScreen(){
        self.performSegueWithIdentifier("backToMainScreen", sender: self)
    }
    
    
    func getAllClubInfo() {
        for club in CLUB_NAMES {
            self.clubInfoArray[club] = 0
        }
        self.clubInfoArray["Not In A Club"] = 0
        
        var query : PFQuery = PFUser.query()!
        query.findObjectsInBackgroundWithBlock { (result:[AnyObject]?, error: NSError?) -> Void in
            
            var currentClubCount : Int = 1
            let resArray = result as! [PFUser]
            for user in resArray{
                let clubName = user["LocationName"] as! String
                //total attendence for each club
                NSLog(clubName)
                self.clubInfoArray[clubName] = self.clubInfoArray[clubName]! + 1
            }
            print("PRINTING SELF ARRAY")
            print(self.clubInfoArray)
            self.setUpAllClubViews()
        }
    }
    
    func getFriendsClubInfo(){
        for club in CLUB_NAMES {
            self.friendsInfoArray[club] = 0
        }
        self.friendsInfoArray["Not In A Club"] = 0
        
        //query to fill info for friends at clubs
        var friendshipQuery: PFQuery = PFQuery(className: "Activity")
        friendshipQuery.whereKey("Type", equalTo: "Friend")
        friendshipQuery.whereKey("From_User", equalTo: PFUser.currentUser()!)//current user
        friendshipQuery.includeKey("To_User")
        var friendQuery : PFQuery = PFUser.query()!
        friendQuery.whereKey("username", matchesKey: "To_User", inQuery: friendshipQuery)
        
        friendQuery.findObjectsInBackgroundWithBlock { (result: [AnyObject]?, error:NSError?) -> Void in
            let resArray = result as! [PFUser]
            for user in resArray {
                let clubName = user["LocationName"] as! String
                if clubName != "Not In A Club" {
                    self.friendsInfoArray[clubName] = self.friendsInfoArray[clubName]! + 1
                }
            }
            self.setUpAllClubViews()
        }
        
    }
    
}

//Mark sidepanelViewControllerDelegate methods

extension MapPageViewController: SidePanelViewControllerDelegate {
    
     func navItemSelected(item: NavItem) {
        delegate?.collapseSidePanels?()
        
        let del = delegate as! ContainerViewController
        let nav = del.centerNavigationController
        
        NSLog("MAPMAPMAPMAP")
        
        if item.title == "View Map"{
            //do nothing 
            //nav.pushViewController(del.mapPageViewController, animated: true)
        }
        else if item.title == "View Friends"{
            del.leftViewController?.delegate = del.friendsViewController
            nav.popToViewController(del.friendsViewController, animated: true)
        }
        else if item.title == "View Clubs"{
            del.leftViewController?.delegate = del.clubsViewController
            nav.popToViewController(del.clubsViewController, animated: true)
        }
    }
}

