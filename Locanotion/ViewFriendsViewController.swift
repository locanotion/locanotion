//
//  FriendsPageViewController.swift
//  Locanotion
//
//  Created by William Bertrand on 3/27/15.
//  Copyright (c) 2015 Locanotion. All rights reserved.
//

import Foundation
import UIKit

class ViewFriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var friendsTableView: UITableView!
    var friends : Array<PFUser> = Array()
    var friendIDs : Array<String> = Array()
    let textCellIdentifier = "FriendCell"
    
    override func viewWillAppear(animated: Bool) {
        //get the user's
        var user = PFUser.currentUser()
        if user == nil {
            //display some error message
        }
        
        
        /*var query = PFUser.query()
        query.findObjectsInBackgroundWithBlock { (objects : [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                for u : PFUser in (objects as [PFUser]) {
                    self.friends.append(u)
                }
                dispatch_async(dispatch_get_main_queue()){
                    self.friendsTableView.reloadData()
                }
            }
        }*/
        
        self.getFacebookFriends()
        
    }
    
    
    func getFacebookFriends() {
        var idArray : Array<String> = Array()
        NSLog("called method")
        var request : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/friends", parameters: nil)
        
        request.startWithCompletionHandler { (connection:FBSDKGraphRequestConnection!, result: AnyObject!, error:NSError!) -> Void in
            NSLog("In handler")
            if error == nil {
                print(result)
                var resultDict : NSDictionary = result as NSDictionary
                print("data we get from result: ")
                var data : NSArray = resultDict.objectForKey("data") as NSArray
                
                let valueDict : NSDictionary = data[0] as NSDictionary
                let id = valueDict.objectForKey("name") as String
                idArray.append(id)
                self.friendIDs.append(id)
                self.friendsTableView.reloadData()
            }
            
        }
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.friendsTableView.reloadData()
        })
        
    }
    
    func getMyFacebookInfo() {
        NSLog("called method")
        var request : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        
        request.startWithCompletionHandler { (connection:FBSDKGraphRequestConnection!, result: AnyObject!, error:NSError!) -> Void in
            NSLog("In handler")
            if error == nil {
                print(result)
                var resultDict : NSDictionary = result as NSDictionary
                print("data we get from result: ")
                var name : String = resultDict.objectForKey("name") as String
                println("the name is : \(name)")
                
            }
            
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if friendIDs.count == 0 {
            NSLog("zero count")
            return 0
        }
        return friendIDs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as FriendViewTableCell
        
        let row = indexPath.row
        let cellUser = friendIDs[row] as String
        //let loc = cellUser["LocationName"] as String
        
        cell.nameLabel.text = cellUser
        cell.locLabel.text = "xx"
        //cell.locImageView.image = UIImage(named: "ViewOnMap")
        return cell
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //double tap, schedule method with delay of .3-.4 seconds, then cancel that action and schedule new action
        //if user does not tap again
        
        var cell : FriendViewTableCell = friendsTableView.cellForRowAtIndexPath(indexPath) as FriendViewTableCell
        self.performSegueWithIdentifier("toDetailView", sender: cell)
        
        friendsTableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toDetailView" {
            //send data over to the detail VC
        }
        
    }
    
}


