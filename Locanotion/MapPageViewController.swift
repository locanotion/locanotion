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
    
    var userLocation : CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    }
    
    func updatePosition(){
        print("updating")
        let region = MKCoordinateRegionMakeWithDistance(
            userLocation.coordinate, 0.1, 0.1)
        
        mapView.setRegion(region, animated: true)

        
        
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
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.getPFUsersWithIDAndAddToMap()
            })
            
        }
        
    }
    
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
    
    func swipeHadler(recognizer:UIGestureRecognizer) {
        //go back to the friends page
        self.performSegueWithIdentifier("backToFriendsView", sender: self)
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        print("updating location")
        var location :CLLocation = locations[locations.count - 1] as! CLLocation
        userLocation = location
        self.updatePosition()
    }
    
}
