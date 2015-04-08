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
        mapView.addAnnotation(userLocationAnnotation)
    }
    
    func updatePosition(){
        print("updating")
        userLocationAnnotation.setCoordinate(userLocation.coordinate)
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
            
            let cpa = annotation as CustomPointAnnotation
            anView.image = UIImage(named: cpa.imageName)
            return anView
            
        }
        
        return nil
    }
    
    func swipeHadler(recognizer:UIGestureRecognizer) {
        //go back to the friends page
        self.performSegueWithIdentifier("backToFriendsView", sender: self)
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        print("updating location")
        var location :CLLocation = locations[locations.count - 1] as CLLocation
       userLocation = location
        self.updatePosition()
    }
    
}
