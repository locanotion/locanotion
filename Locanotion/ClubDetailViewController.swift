//
//  ClubDetailViewController.swift
//  Locanotion
//
//  Created by William Bertrand on 4/19/15.
//  Copyright (c) 2015 Locanotion. All rights reserved.
//

import Foundation

class ClubDetailViewController : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    var clubName : String!
    var numImages : Int!
    
    @IBOutlet var clubNameLabel: UILabel!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var statusImageView : UIImageView!
    var totalAttendanceNumberLabel : UILabel!
    var friendAttendanceNumberLabel : UILabel!
    var pictureView : UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clubNameLabel.text = clubName
        backButton.layer.cornerRadius = 3
        let frameForPhotoView = CGRect(x:0, y:(self.view.frame.height / 6) * 5, width: self.view.frame.width, height: self.view.frame.height / 6)
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 100, height: self.view.frame.height / 6)
        layout.scrollDirection = .Horizontal
        pictureView = UICollectionView(frame: frameForPhotoView, collectionViewLayout: layout)
        pictureView.dataSource = self
        pictureView.delegate = self
        pictureView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "pictureCell")
        numImages = 5
        pictureView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(pictureView)
        
    }
    
    func getClubInfo(name:String){
        var clubInfoQuery = PFQuery(className: "Club")
        clubInfoQuery.whereKey("Club_Name", equalTo: name)
        
        clubInfoQuery.findObjectsInBackgroundWithBlock { (result:[AnyObject]?, error:NSError?) -> Void in
            let resultObjects = result as! [PFObject]
            let clubObject : PFObject = resultObjects[0]
            
            let clubOpen : Bool = clubObject["Open"] as! Bool
            if clubOpen {
                self.statusImageView.image = UIImage(named: "ClubOpen")
            }
            else {
                self.statusImageView.image = UIImage(named: "ClubClosed")

            }
            
            self.friendAttendanceNumberLabel.text = "0" //clubObject[""] as! String
            self.totalAttendanceNumberLabel.text = "0" //clubObject[""] as! String
            
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numImages
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("pictureCell", forIndexPath: indexPath) as! UICollectionViewCell
        
        let photoView : UIImageView = UIImageView(frame: cell.contentView.frame)
        if indexPath.row == 0 {
            let image = UIImage(named: "addPhotoImage")
            photoView.image = image
        }
        else {
            let image = UIImage(named: "testImage")
            photoView.image = image
        }
        cell.contentView.addSubview(photoView)
        
        return cell
    }
    
}