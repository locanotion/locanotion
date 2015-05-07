//
//  FriendsPageViewController.swift
//  Locanotion
//
//  Created by William Bertrand on 3/27/15.
//  Copyright (c) 2015 Locanotion. All rights reserved.
//


//TODO:
//Change way that friends are aquired to using a Friendship Activity

import Foundation
import UIKit

class ViewFriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var friendsTableView: UITableView!
    var friendNames : Array<String> = Array()
    var friendIDs : Array<String> = Array()
    var friendLocations : Array<String> = Array()
    var friendCellArray : Array<FriendViewTableCell> = Array()
    let textCellIdentifier = "FriendCell"
    var backButton : UIButton!
    
    var selectedName : String!
    var SelectedFriendID : String!
    
    //Properties for side-panel menu
    var delegate: CenterViewControllerDelegate?
    
    var menuButton : UIButton!
    
    override func viewWillAppear(animated: Bool) {
        NSLog("WILL APPEAR")
        self.friendsTableView.reloadData()
        //get the user's
        var user = PFUser.currentUser()
        if user == nil {
            //display some error message
        }
        self.getFacebookFriends()
        
        //var timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: Selector("reloadPage"), userInfo: nil, repeats: true)
        
    }
    
    func reloadPage(){
        NSLog("Reloading the page")
        self.getFacebookFriends()
        // self.friendsTableView.reloadData()
    }
    
    
    override func viewDidLayoutSubviews() {
        menuButton = UIButton(frame:CGRect(x: 10, y: 25, width: 40, height: 30))
        menuButton.setBackgroundImage(UIImage(named: "MenuIcon"), forState: UIControlState.Normal)
        menuButton.addTarget(self, action: "menuTapped", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(menuButton)
    }
    
    func menuTapped() {
        delegate?.toggleLeftPanel?()
    }
    
    
    func getFacebookFriends() {
        friendIDs.removeAll()
        friendNames.removeAll()
        friendLocations.removeAll()
       /* if self.friendLocations.count > 0 {
            self.friendLocations.removeAll()
        }
        if !self.friendNames.isEmpty{
            self.friendNames.removeAll()
        }*/
        NSLog("called method")
        var request : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/friends", parameters: nil)
        
        request.startWithCompletionHandler { (connection:FBSDKGraphRequestConnection!, result: AnyObject!, error:NSError!) -> Void in
            NSLog("In handler")
            if error == nil {
                print(result)
                var resultDict : NSDictionary = result as! NSDictionary
                var data : NSArray = resultDict.objectForKey("data") as! NSArray
                for value in data {
                    let valueDict : NSDictionary = value as! NSDictionary
                    let id = valueDict.objectForKey("id") as! String
                    var name = (valueDict.objectForKey("name") as! String)
                    self.friendIDs.append(id)
                    self.friendNames.append(name)
                    NSLog("friend id's : \(self.friendIDs)")
                    
                    let userQuery = PFUser.query()
                    userQuery?.whereKey("facebook_ID", equalTo: id)
                    userQuery?.findObjectsInBackgroundWithBlock({ (result:[AnyObject]?, error:NSError?) -> Void in
                        if result != nil {
                            NSLog("not nil")
                            let res = result as! [PFUser]
                            let user = res.first!
                            let loc : String = user["LocationName"] as! String
                            self.friendLocations.append(loc)
                            self.friendsTableView.reloadData()
                        }
                        NSLog("ended friend query")
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
    
    func getMyFacebookInfo() {
        var request : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        
        request.startWithCompletionHandler { (connection:FBSDKGraphRequestConnection!, result: AnyObject!, error:NSError!) -> Void in
            NSLog("In handler")
            if error == nil {
                print(result)
                var resultDict : NSDictionary = result as! NSDictionary
                print("data we get from result: ")
                var name : String = resultDict.objectForKey("name") as! String
                println("the name is : \(name)")
                
            }
            
            
        }
    }
    
    
    func getFriendLocations() {
        self.friendLocations.removeAll()
        self.friendNames.removeAll()
        
        if self.friendIDs.count > 0 {
            
            //friend query
            var query : PFQuery = PFQuery(className: "Activity")
            query.whereKey("From_User", equalTo: PFUser.currentUser()!)
            query.includeKey("To_User")
            query.findObjectsInBackgroundWithBlock({ (result:[AnyObject]?, error:NSError?) -> Void in
                NSLog("firstQueryCount: \(result!.count)")
                let resultArray = result as! [PFObject]
                for res in resultArray {
                    let user = res["To_User"] as! PFUser
                    NSLog(user["Full_Name"] as! String)
                
                    
                }
            })
            
            //get friend PFUsers
            var friendQuery : PFQuery = PFUser.query()!
            friendQuery.whereKey("facebook_ID", containedIn: self.friendIDs)
            
            friendQuery.findObjectsInBackgroundWithBlock({ (objects:[AnyObject]?, error:NSError?) -> Void in
                if error != nil {
                    NSLog("Error finding friend objects")
                }
                let results : [PFUser] = objects as! [PFUser]
                NSLog("results count: %d", results.count)
                for user in results {
                    let name : String = user["Full_Name"] as! String
                    self.friendNames.append(name)
                    let loc : String = user["LocationName"] as! String
                    self.friendLocations.append(loc)
                    NSLog("name:\(name) loc: \(loc)")
                    
                }
                self.friendsTableView.reloadData()
                
            })
            
            
        }
        else {
            //no friends
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
        if friendNames.count == 0 {
            NSLog("zero count")
            return 0
        }
        if friendNames.count != friendLocations.count {
            return 0
        }
        NSLog("Returning num rows: \(friendNames.count)")
        return friendNames.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        NSLog("making cell for row:\(indexPath.row)")
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as! FriendViewTableCell
        
        let row = indexPath.row
        NSLog("counts: \(friendNames.count) : \(friendLocations.count)")

        let cellUser = friendNames[row] as String
        let cellLoc = friendLocations[row] as String
        //let loc = cellUser["LocationName"] as String
        
        cell.nameLabel.text = cellUser
        
        cell.locLabel.text = cellLoc
        
        //cell.locImageView.image = UIImage(named: "ViewOnMap")
        NSLog("returning cell")
        return cell
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //double tap, schedule method with delay of .3-.4 seconds, then cancel that action and schedule new action
        //if user does not tap again
        
        var cell : FriendViewTableCell = friendsTableView.cellForRowAtIndexPath(indexPath) as! FriendViewTableCell
        self.selectedName = cell.nameLabel.text
        self.SelectedFriendID = self.friendIDs[indexPath.row]
        
        
        let del = delegate as! ContainerViewController
        let nav = del.centerNavigationController
        del.friendsDetailViewController.friendName = self.selectedName
        del.friendsDetailViewController.friendFacebook_ID = self.SelectedFriendID
        
        nav.pushViewController(del.friendsDetailViewController, animated: true)
        
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toDetailView" {
            //send data over to the detail VC
            var destViewController : FriendDetailViewControlelr = segue.destinationViewController as! FriendDetailViewControlelr
            destViewController.friendName = selectedName
        }
        
    }
    
    func backToMainScreen(){
        self.performSegueWithIdentifier("backToMainScreen", sender: self)
    }
    
    func emptyArrays(){
        self.friendIDs.removeAll() //keepCapacity: false)
        self.friendNames.removeAll() //keepCapacity: false)
        self.friendLocations.removeAll() //keepCapacity: false)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSLog("leaving\(self.friendIDs.count)")
        self.friendIDs.removeAll()
        self.friendNames.removeAll()
        self.friendLocations.removeAll()
    }
    
}

//Mark sidepanelViewControllerDelegate methods

extension ViewFriendsViewController: SidePanelViewControllerDelegate {
    
    func navItemSelected(item: NavItem) {
        delegate?.collapseSidePanels?()
        
        let del = delegate as! ContainerViewController
        let nav = del.centerNavigationController
        
        NSLog("FRIENDSFRIENDSFRIENDS")
        
        if item.title == "View Map"{
            del.leftViewController?.delegate = del.mapPageViewController
            nav.popToViewController(del.mapPageViewController, animated: true)
        }
        else if item.title == "View Friends"{
            //do nothing
            //nav.pushViewController(del.friendsViewController, animated: true)
        }
        else if item.title == "View Clubs"{
            del.leftViewController?.delegate = del.clubsViewController
            nav.popToViewController(del.clubsViewController, animated: true)
        }
    }
}
