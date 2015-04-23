//
//  ViewClubsViewController.swift
//  Locanotion
//
//  Created by William Bertrand on 4/19/15.
//  Copyright (c) 2015 Locanotion. All rights reserved.
//

import Foundation

class ViewClubsViewController : UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    @IBOutlet var backButton : UIButton!
    var clubCollectionView : UICollectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let voleColor = UIColor(red: 178, green: 225, blue: 249, alpha: 1.0)
        self.view.backgroundColor = voleColor
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top:0, left:0, bottom: 0, right:0)
        layout.itemSize = CGSize(width: self.view.frame.width, height: 200)
        layout.scrollDirection = .Vertical
        let clubCollectionViewFrame = CGRect(x: 0, y: 50, width: self.view.frame.width, height: self.view.frame.height)
        
        backButton.layer.cornerRadius = 3
        clubCollectionView = UICollectionView(frame: clubCollectionViewFrame, collectionViewLayout: layout)
        clubCollectionView!.dataSource = self
        clubCollectionView!.delegate = self
        clubCollectionView!.registerClass(ClubCollectionViewCell.self, forCellWithReuseIdentifier: "ClubCell")
        clubCollectionView!.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(clubCollectionView!)
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return NUM_CLUBS
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ClubCell", forIndexPath: indexPath) as! ClubCollectionViewCell
        if indexPath.row == 0 {
            cell.clubNameLabel.text = "Tonight's Most Popular Club"
            cell.clubOpenLabel.text = ""
            cell.clubAttendanceLabel.text = "0"
        }
        else {
            cell.clubNameLabel.text = CLUB_NAMES[indexPath.row - 1]
            cell.clubOpenLabel.text = "Closed"
            cell.clubAttendanceLabel.text = "0"
            var name : String = CLUB_NAMES[indexPath.row - 1] + "CellImage"
            cell.clubImageView.image = UIImage(named: name)
        }
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            
        }
        else {
            self.performSegueWithIdentifier("toDetailClubView", sender: CLUB_NAMES[indexPath.row - 1])
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toDetailClubView" {
            let destVC = segue.destinationViewController as! ClubDetailViewController
            let clubName = sender as! String
            destVC.clubName = clubName
        }
    }
    
}
