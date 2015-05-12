//
//  ViewClubsViewController.swift
//  Locanotion
//
//  Created by William Bertrand on 4/19/15.
//  Copyright (c) 2015 Locanotion. All rights reserved.
//

import Foundation
class ViewClubsViewController : UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    var menuButton : UIButton!
    var clubCollectionView : UICollectionView?
    var mostPopularClub : String!
    
    //Properties for side-panel menu
    var delegate: CenterViewControllerDelegate?
    
    ///Array of tuples:(string,int) to hold club, num people
    var clubInfoArray = [String: Int]()
    //another array to hold just friend attendence counts
    var friendsInfoArray = [String: Int]()
    
    //open array
    var clubOpenInfo = [String: String]()
    
    //lazily instantiated refesch control variable that declares which function should be called when the collection
    //is pulled to refresh
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let flockColor = UIColor(red: 178, green: 225, blue: 249, alpha: 1.0)
        self.view.backgroundColor = flockColor
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top:0, left:0, bottom: 0, right:0)
        layout.itemSize = CGSize(width: self.view.frame.width, height: 200)
        layout.scrollDirection = .Vertical
        let clubCollectionViewFrame = CGRect(x: 0, y: 20, width: self.view.frame.width, height: self.view.frame.height)
        
        
        clubCollectionView = UICollectionView(frame: clubCollectionViewFrame, collectionViewLayout: layout)
        clubCollectionView!.dataSource = self
        clubCollectionView!.delegate = self
        clubCollectionView!.registerClass(ClubCollectionViewCell.self, forCellWithReuseIdentifier: "ClubCell")
        clubCollectionView!.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(clubCollectionView!)
        
        menuButton = UIButton(frame:CGRect(x: 10, y: 25, width: 40, height: 30))
        menuButton.setBackgroundImage(UIImage(named: "MenuIcon"), forState: UIControlState.Normal)
        menuButton.addTarget(self, action: "menuTapped", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(menuButton)
        
        clubCollectionView?.addSubview(self.refreshControl)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        for club in CLUB_NAMES {
            friendsInfoArray[club] = 0
            clubInfoArray[club] = 0
            clubOpenInfo[club] = "Default"
        }
        self.getAllClubInfo()
    }
    
    
    //tell the delegate to slide out the left menu panel
    func menuTapped() {
        delegate?.toggleLeftPanel?()
    }
    
    
    //get the info for all the clubs from parse 
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
        for club1 in CLUB_NAMES {
            self.friendsInfoArray[club1] = 0
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
                        self.clubCollectionView?.reloadData()
                        
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

    
    
    //Mark : Collection View Delegate Methods
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return NUM_CLUBS
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ClubCell", forIndexPath: indexPath) as! ClubCollectionViewCell
        if indexPath.row == -1 {
            /*cell.clubNameLabel.text = "Tonight's Most Popular Club"
            cell.clubOpenLabel.text = "club name"
            cell.clubAttendanceLabel.text = "0"
            cell.clubImageView.image = UIImage(named: "lightShow")*/
        }
        else {
            var title = CLUB_NAMES[indexPath.row]
            let friends : Int = friendsInfoArray[CLUB_NAMES[indexPath.row]]!
            let total : Int = clubInfoArray[CLUB_NAMES[indexPath.row]]!
            var fraction : String = "(" + (friends as NSNumber).stringValue + "/" + (total as NSNumber).stringValue + ")"
            cell.clubNameLabel.text = title + " " + fraction
            var name : String = CLUB_NAMES[indexPath.row] + "CellImage"
            cell.clubImageView.image = UIImage(named: name)
        }
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == -1 {
            
        }
        else {
            //self.performSegueWithIdentifier("toDetailClubView", sender: CLUB_NAMES[indexPath.row - 1])
            let del = delegate as! ContainerViewController
            let nav = del.centerNavigationController
            del.clubDetailViewController.clubName = CLUB_NAMES[indexPath.row]
            del.clubDetailViewController.totalAttendance = clubInfoArray[CLUB_NAMES[indexPath.row]]
            del.clubDetailViewController.friendAttendance = friendsInfoArray[CLUB_NAMES[indexPath.row]]
            
            if clubOpenInfo[CLUB_NAMES[indexPath.row]]! == "Open" {
                del.clubDetailViewController.open = true
            }
            else {
                del.clubDetailViewController.open = false
            }
            nav.pushViewController(del.clubDetailViewController, animated: true)
        }
    }
    
    //refresh method for the table view
    func handleRefresh(refreshControl: UIRefreshControl) {
        // re-query the database and refresh the table
        self.getAllClubInfo()
        refreshControl.endRefreshing()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toDetailClubView" {
            let destVC = segue.destinationViewController as! ClubDetailViewController
            let clubName = sender as! String
            destVC.clubName = clubName
        }
    }
    
    func getMostPopularClub(){
        var clubQuery : PFQuery = PFQuery(className: "Club")
        clubQuery.orderByDescending("Attendance")
        clubQuery.findObjectsInBackgroundWithBlock { (objects:[AnyObject]?, error:NSError?) -> Void in
            if error == nil {
                self.mostPopularClub = ""
                for object in (objects as! [PFObject]){
                    
                }
            }
        }
    }
    
    
    
}


//Mark sidepanelViewControllerDelegate methods

extension ViewClubsViewController: SidePanelViewControllerDelegate {
    
    func navItemSelected(item: NavItem) {
        delegate?.collapseSidePanels?()
        
        let del = delegate as! ContainerViewController
        let nav = del.centerNavigationController
        
        NSLog("CLUBSCLUBSCLUBS")
        
        if item.title == "View Map"{
            del.leftViewController?.delegate = del.mapPageViewController
            nav.popToViewController(del.mapPageViewController, animated: true)
        }
        else if item.title == "View Friends"{
            del.leftViewController?.delegate = del.friendsViewController
            nav.popToViewController(del.friendsViewController, animated: true)
        }
        else if item.title == "View Clubs"{
            //do nothing
            //nav.pushViewController(del.clubsViewController, animated: true)
        }
    }
}
