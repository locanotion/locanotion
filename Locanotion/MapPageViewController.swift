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
    var clubInfoArray:[(String, Int)] = []
    //another array to hold just friend attendence counts
    var friendsInfoArray = [String: Int]()
    
    

    
    
    
    var backButton : UIButton!
    var userLocation : CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for club in CLUB_NAMES {
            friendsInfoArray[club] = 0
        }
        print(friendsInfoArray)
        
        
        backButton = UIButton(frame:CGRect(x: 0, y: 0, width: 100, height: 40))
        backButton.setTitle("Back", forState: UIControlState.Normal)
        backButton.layer.backgroundColor = UIColor.orangeColor().CGColor
        backButton.layer.cornerRadius = 3
        backButton.addTarget(self, action: "backToMainScreen", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(backButton)
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
            CLLocationCoordinate2D(latitude: 40.344314, longitude: -74.655556), 2000, 2000)
        
        mapView.setRegion(region, animated: true)
        
        //mapView.addAnnotation(userLocationAnnotation)
        self.getFacebookFriendsLocations()
        
        self.getAllClubInfo()
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
            anView.image = UIImage(named: cpa.imageName)
            
            return anView
            
        }
        
        return nil
    }
    
    func addFriendPointsToMap() {
        //get the friends last lat and long and add annotation to mapview
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
    
    //Won't be using this for now
    /*
    func getPFUsersWithIDAndAddToMap(){
        var friendQuery : PFQuery = PFUser.query()!
        NSLog("friendIDS %d", friendIDs.count)
        friendQuery.whereKey("facebook_ID", equalTo: friendIDs[0])
        friendQuery.findObjectsInBackgroundWithBlock { (result:[AnyObject]?, error:NSError?) -> Void in
            if error == nil {
                //get the loc for each friend and add annotation to map view
                for res in (result as! [PFUser]!) {
                    var resUser : PFUser = res as PFUser
                    var lat : CLLocationDegrees = resUser["Last_Lat"] as! CLLocationDegrees
                    var lon : CLLocationDegrees = resUser["Last_Long"] as! CLLocationDegrees
                    
                    var friendAnnoation : CustomPointAnnotation = CustomPointAnnotation()
                    friendAnnoation.imageName = "FriendPoint"
                    //friendAnnoation.setCoordinate(CLLocationCoordinate2D(latitude: lat, longitude: lon))
                    friendAnnoation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    self.mapView.addAnnotation(friendAnnoation)
                }
                
            }
        }
    }
    */
    
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
    
    
    func displayClubAnnotations() {
        for loc in GLOBAL_ClubLocations {
            var clubAnnot = CustomPointAnnotation()
            clubAnnot.imageName = "testClub"
            clubAnnot.type = "clubLabel"
            clubAnnot.coordinate = loc.coordinate
            mapView.addAnnotation(clubAnnot)
        }
    }
    
    
    func getAllClubInfo() {
        var query : PFQuery = PFUser.query()!
        query.orderByDescending("At_Club")
        
        query.findObjectsInBackgroundWithBlock { (result:[AnyObject]?, error: NSError?) -> Void in
            
            var currentClubCount : Int = 1
            let resArray = result as! [PFUser]
            let firstUser = resArray[0] as PFUser
            var currentClub : String = firstUser["LocationName"] as! String
            for user in resArray{
                //total attendence for each club
                if currentClub == (user["LocationName"] as! String) {
                    currentClubCount++
                }
                else {
                    self.clubInfoArray += [(currentClub, currentClubCount)]
                    currentClubCount = 1
                    currentClub = user["LocationName"] as! String
                }
                
            }
            print("PRINTING SELF ARRAY")
            print(self.clubInfoArray)
        }
    }
    
    func getFriendsClubInfo(){
        var friendQuery: PFQuery = PFQuery(className: "Activity")
        friendQuery.whereKey("Type", equalTo: "Friend")
        friendQuery.whereKey("From_User", equalTo: PFUser.currentUser()!) //check this to make sure linking with current user works correctly
        friendQuery.findObjectsInBackgroundWithBlock { (result: [AnyObject]?, error:NSError?) -> Void in
            let resArray = result as! [PFUser]
            for user in resArray {
                let clubName = user["LocationName"] as! String
                self.friendsInfoArray[clubName] = self.friendsInfoArray[clubName]! + 1
            }
            
        }
        
    }
    
}
