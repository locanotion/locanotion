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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let voleColor = UIColor(red: 178, green: 225, blue: 249, alpha: 1.0)
        self.view.backgroundColor = voleColor
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
        
    }
    
    func menuTapped() {
        delegate?.toggleLeftPanel?()
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return NUM_CLUBS + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ClubCell", forIndexPath: indexPath) as! ClubCollectionViewCell
        if indexPath.row == 0 {
            cell.clubNameLabel.text = "Tonight's Most Popular Club"
            cell.clubOpenLabel.text = "club name"
            cell.clubAttendanceLabel.text = "0"
            cell.clubImageView.image = UIImage(named: "lightShow")
        }
        else {
            cell.clubNameLabel.text = CLUB_NAMES[indexPath.row - 1]
            cell.clubOpenLabel.text = "Closed"
            cell.clubAttendanceLabel.text = "0" //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!ADD THIS
            var name : String = CLUB_NAMES[indexPath.row - 1] + "CellImage"
            cell.clubImageView.image = UIImage(named: name)
        }
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            
        }
        else {
            //self.performSegueWithIdentifier("toDetailClubView", sender: CLUB_NAMES[indexPath.row - 1])
            let del = delegate as! ContainerViewController
            let nav = del.centerNavigationController
            NSLog("clicked:\(CLUB_NAMES[indexPath.row - 1])")
            del.clubDetailViewController.clubName = CLUB_NAMES[indexPath.row - 1]
            //del.clubDetailViewController.clubNameLabel.text = CLUB_NAMES[indexPath.row - 1]
            NSLog(del.clubDetailViewController.clubName)
            nav.pushViewController(del.clubDetailViewController, animated: true)
        }
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
    
    func backToMainScreen(){
        self.performSegueWithIdentifier("backToMainScreen", sender: self)
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
