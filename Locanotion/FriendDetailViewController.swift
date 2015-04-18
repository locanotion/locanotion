//
//  FriendDetailViewController.swift
//  Locanotion
//
//  Created by William Bertrand on 4/3/15.
//  Copyright (c) 2015 Locanotion. All rights reserved.
//

import Foundation
import MapKit

class FriendDetailViewControlelr: UIViewController {
    
    
    var friendFacebook_ID : String = String()
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var backButton : UIButton!
    @IBOutlet var detailScrollView : UIScrollView!
    @IBOutlet var friendNameLabel : UILabel!
    var friendName : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.layer.cornerRadius = 3
        friendNameLabel.text = friendName
        
        //set up the map: 40.348477, -74.652612
        let location = CLLocationCoordinate2D(latitude: 40.348477, longitude: -74.652612)
        let span = MKCoordinateSpanMake(0.02, 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        
        mapView.setRegion(region, animated: true)
        
        //set up the detail scroll view 
        
        
    }
}