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
    var friendUser : PFUser!
    var friendName : String!
    var friendID : String!
    var friendLoc : String!
    var friendHistory : Array<String>!
    var historyScrollView : UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.layer.cornerRadius = 3
        friendNameLabel.text = friendName
        
        //set up the map: 40.348477, -74.652612
        let location = CLLocationCoordinate2D(latitude: 40.348477, longitude: -74.652612)
        let span = MKCoordinateSpanMake(0.02, 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        
        mapView.setRegion(region, animated: true)
        
        
        var label = UILabel(frame: CGRect(x: 0, y: (self.view.frame.height / 2) - 40, width: 100, height: 40))
        label.text = "\(friendName)'s History"
        label.font = UIFont(name: "Avenir Next", size: 14)
        label.textColor = VOLE_COLOR
        self.view.addSubview(label)
        historyScrollView.frame = CGRect(x: 0, y: self.view.frame.height / 2, width: self.view.frame.width, height: self.view.frame.height / 2)
        historyScrollView.backgroundColor = VOLE_COLOR
        self.view.addSubview(historyScrollView)
        
        
        
    }
    
    
    func sendPushNotificationTo(userName:String){
        
    }
    
    func getUserInfoFromFacebookID(){
        var userQuery : PFQuery = PFUser.query()!
        userQuery.whereKey("facebook_ID", equalTo: friendID)
        userQuery.findObjectsInBackgroundWithBlock { (result:[AnyObject]?, error:NSError?) -> Void in
            let user = result?.first as! PFUser
            self.friendUser = user
            self.friendLoc = user["LocationName"] as! String
            self.friendHistory = user["history"] as! Array<String>
            
            if self.friendHistory.count == 0 {
                
            }
            else {
                self.setUpHistoryTable()
            }
        }
    }
    
    func setUpHistoryTable() {
        var frame = CGRect(x: 10, y: 0, width: self.view.frame.width, height: 40)
        for i in 0 ..< friendHistory.count {
            frame.origin.y = CGFloat(i) * frame.height
            var label = UILabel(frame: frame)
            label.font = UIFont(name: "Avenir Next", size: 14)
            label.text = friendHistory[i]
            self.historyScrollView.addSubview(label)
        }
        
        self.historyScrollView.contentSize = CGSize(width: self.view.frame.width, height: (frame.height * CGFloat(friendHistory.count)) + 200)
        
    }
    
}




