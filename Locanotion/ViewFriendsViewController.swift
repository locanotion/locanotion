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
    var friendTuples : Array<(String, String)> = Array()
    
    var friendinfo = [String : String]()
    
    var friendCellArray : Array<FriendViewTableCell> = Array()
    let textCellIdentifier = "FriendCell"
    var backButton : UIButton!
    
    var selectedName : String!
    var SelectedFriendID : String!
    
    //Properties for side-panel menu
    var delegate: CenterViewControllerDelegate?
    
    var menuButton : UIButton!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
        }()
    
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
        friendTuples.removeAll()
     
        NSLog("called method")
        var request : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/friends", parameters: nil)
        
        request.startWithCompletionHandler { (connection:FBSDKGraphRequestConnection!, result: AnyObject!, error:NSError!) -> Void in
            NSLog("In handler")
            if error == nil {
                print(result)
                var resultDict : NSDictionary = result as! NSDictionary
                var data : NSArray = resultDict.objectForKey("data") as! NSArray
                NSLog("found \(data.count) from facebook")
                for value in data {
                    let valueDict : NSDictionary = value as! NSDictionary
                    let id = valueDict.objectForKey("id") as! String
                    var name = (valueDict.objectForKey("name") as! String)
                    
                    let userQuery = PFUser.query()
                    userQuery?.whereKey("facebook_ID", equalTo: id)
                    userQuery?.findObjectsInBackgroundWithBlock({ (result:[AnyObject]?, error:NSError?) -> Void in
                        if result != nil {
                            NSLog("found \(result!.count) from parse")
                            if result!.count != 0 {
                                NSLog("not nil")
                                let res = result as! [PFUser]
                                let user = res.first!
                                let loc : String = user["LocationName"] as! String
                                let username = user["Full_Name"] as! String
                                let cur_tuple = (username, loc)
                                self.friendTuples.append(cur_tuple)
                                
                                self.friendinfo[user["Full_Name"] as! String] = user["LocationName"] as! String
                                //sort the array of tubles by the first element(the names)
                                self.friendTuples.sort { $0.0 < $1.0 }
                                self.friendsTableView.reloadData()
                                self.refreshing = false
                            }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        
        self.friendsTableView.addSubview(self.refreshControl)
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendTuples.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        NSLog("making cell for row:\(indexPath.row)")
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as! FriendViewTableCell
        
        let row = indexPath.row
        
        let (name, loc) = friendTuples[row] as (String, String)
        
        let cellUser = name
        let cellLoc = loc
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
        
        
        
    }
    
    
    func backToMainScreen(){
        self.performSegueWithIdentifier("backToMainScreen", sender: self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.friendTuples.removeAll()
    }
    
    var refreshing : Bool = false
    //refresh method for the table view
    func handleRefresh(refreshControl: UIRefreshControl) {
        
        if !refreshing{
            refreshing = true
            // re-query the database and refresh the table
            self.getFacebookFriends()
            refreshControl.endRefreshing()
        }
        else {
            refreshControl.endRefreshing()
        }
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
