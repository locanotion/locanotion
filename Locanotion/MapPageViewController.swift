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
    var MapViewAnnotations : Array<MKAnnotation> = Array()
    
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
        //self.getFriendsClubInfo()
    }
    
    override func viewWillAppear(animated: Bool) {
        NSLog("appear")
        //self.getAllClubInfo()
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSLog("disappear")
        self.clubInfoArray.removeAll()
        self.friendsInfoArray.removeAll()
        mapView.removeAnnotations(MapViewAnnotations)
        self.getAllClubInfo()
    }
    
    func menuTapped() {
        delegate?.toggleLeftPanel?()
    }

    
    //create an annotation for each club and add it to the map
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation is CustomPointAnnotation {
             NSLog("SET UP YYYYYYYYYY")
            let cpaAnnotation = annotation as! CustomPointAnnotation
            let reuseID = cpaAnnotation.name
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
            var intA : Int = self.friendsInfoArray[cpa.name]!
            if intA == 1 {
                friendLabel.text = String(intA) + " Bird of a feather"
            }
            else{
                friendLabel.text = String(intA) + " Birds of a feather"
            }
            friendLabel.textAlignment = .Center
            friendLabel.font = UIFont(name: "Avenir Next", size: 9)
            anView.addSubview(friendLabel)
            //add total attendence label
            let totalFrame = CGRect(x: 0, y: textFrame.height + FriendFrame.height, width: frame.width, height: frame.height / 3)
            let totalLabel = UILabel(frame: totalFrame)
            totalLabel.textAlignment = .Center
            let intB : Int = self.clubInfoArray[cpa.name]!
            totalLabel.text = "Flock Size: " + String(intB)
            totalLabel.font = UIFont(name: "Avenir Next", size: 11)
            anView.addSubview(totalLabel)
            return anView
            
        }
        
        return nil
    }
    func setUpAllClubViews() {
        MapViewAnnotations.removeAll()
        for clubx in 0 ..< GLOBAL_ClubLocations.count {
            let cpa = CustomPointAnnotation()
            cpa.coordinate = GLOBAL_ClubLocations[clubx].coordinate
            cpa.name = CLUB_NAMES[clubx]
            cpa.imageName = "annotation"
            cpa.friendAttendence = friendsInfoArray[CLUB_NAMES[clubx]]
            cpa.totalAttendence = clubInfoArray[CLUB_NAMES[clubx]]
            mapView.addAnnotation(cpa)
            MapViewAnnotations.append(cpa)
        }
    }

    
    func getFacebookFriendsLocations() {
        var idArray : Array<String> = Array()
                var request : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/friends", parameters: nil)
        
        request.startWithCompletionHandler { (connection:FBSDKGraphRequestConnection!, result: AnyObject!, error:NSError!) -> Void in
                        if error == nil {
                print(result)
                var resultDict : NSDictionary = result as! NSDictionary
                
                
                var data : NSArray = resultDict.objectForKey("data") as! NSArray
                
                let valueDict : NSDictionary = data[0] as! NSDictionary
                let id = valueDict.objectForKey("id") as! String
                idArray.append(id)
                self.friendIDs.append(id)
                
            }
        }
        
    }
    
    func swipeHadler(recognizer:UIGestureRecognizer) {
        //go back to the friends page
        self.performSegueWithIdentifier("backToFriendsView", sender: self)
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
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
        self.clubInfoArray["Migrating"] = 0
        
        var peopleQuery = PFUser.query()
        peopleQuery?.findObjectsInBackgroundWithBlock({ (result:[AnyObject]?, error:NSError?) -> Void in
            
            let resultArray = result as! [PFUser]
            for user in resultArray {
                let clubName = user["LocationName"] as! String
                self.clubInfoArray[clubName] = self.clubInfoArray[clubName]! + 1
            }
            self.getFriendsClubInfo()
        })
        
    }
    
    
    //get info for all of the user's friends based on their facebok ID's
    func getFriendsClubInfo() {
        for club in CLUB_NAMES {
            self.friendsInfoArray[club] = 0
        }
        self.friendsInfoArray["Migrating"] = 0
        
        var request : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/friends", parameters: nil)
        
        request.startWithCompletionHandler { (connection:FBSDKGraphRequestConnection!, result: AnyObject!, error:NSError!) -> Void in
            if error == nil {
                print(result)
                var resultDict : NSDictionary = result as! NSDictionary
                var data : NSArray = resultDict.objectForKey("data") as! NSArray
                for value in data {
                    let valueDict : NSDictionary = value as! NSDictionary
                    let id = valueDict.objectForKey("id") as! String
                    var name = (valueDict.objectForKey("name") as! String)
                    
                    let userQuery = PFUser.query()
                    userQuery?.whereKey("facebook_ID", equalTo: id)
                    userQuery?.findObjectsInBackgroundWithBlock({ (result:[AnyObject]?, error:NSError?) -> Void in
                        if result != nil {
                            if result!.count != 0 {
                                NSLog("not nil")
                                let res = result as! [PFUser]
                                let user = res.first!
                                let loc : String = user["LocationName"] as! String
                                self.friendsInfoArray[loc] = self.friendsInfoArray[loc]! + 1
                            }
                        }
                        NSLog("ended friend query")
                        //now that queries are done, update the map views
                        self.setUpAllClubViews()
                        
                    })
                }
                //todo: implement pic request
                //var picRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "\(id)/friends", parameters: nil)
                
                // picRequest.startWithCompletionHandler({ (FBSDKGraphRequestConnection?, result:AnyObject!, error:NSError!) -> Void in
                //get data array, i guess data[0] will be the prof picture
                //})
                
                //self.getFriendLocations()
            }
            
        }
        
    }

    
    
}



//Mark sidepanelViewControllerDelegate methods

extension MapPageViewController: SidePanelViewControllerDelegate {
    
     func navItemSelected(item: NavItem) {
        delegate?.collapseSidePanels?()
        
        let del = delegate as! ContainerViewController
        let nav = del.centerNavigationController
        
        
        
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

