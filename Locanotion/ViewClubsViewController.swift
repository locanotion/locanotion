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
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 160, height: 160)
        let clubCollectionViewFrame = CGRect(x: 0, y: 100, width: self.view.frame.width, height: self.view.frame.height - 100)
        
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
        cell.backgroundColor = UIColor.cyanColor()
        cell.clubNameLabel.text = CLUB_NAMES[indexPath.row]
        cell.clubOpenLabel.text = "Closed"
        cell.clubAttendanceLabel.text = "0"
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("toDetailClubView", sender: CLUB_NAMES[indexPath.row])
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toDetailClubView" {
            let destVC = segue.destinationViewController as! ClubDetailViewController
            let clubName = sender as! String
            destVC.clubName = clubName
        }
    }
    
}
