//
//  ClubDetailViewController.swift
//  Locanotion
//
//  Created by William Bertrand on 4/19/15.
//  Copyright (c) 2015 Locanotion. All rights reserved.
//

import Foundation
import MobileCoreServices

class ClubDetailViewController : UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    var clubName : String!
    var numImages : Int!
    
    @IBOutlet var clubNameLabel: UILabel!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var statusImageView : UIImageView!
    @IBOutlet var totalAttendanceNumberLabel : UILabel!
    @IBOutlet var friendAttendanceNumberLabel : UILabel!
    var totalAttendance : Int!
    var friendAttendance : Int!
    var open : Bool!
    var pictureView : UICollectionView!
    var pictureArray : Array<UIImage> = Array()
    
    //Properties for side-panel menu
    var delegate: CenterViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clubNameLabel.text = clubName
        backButton.layer.cornerRadius = 3
        backButton.frame = CGRect(x: 10, y: 60, width: 100, height: 40)
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
    
    override func viewWillAppear(animated: Bool) {
        //set text labels
        totalAttendanceNumberLabel.text = " Flock Size: " + String(totalAttendance)
        if friendAttendance == 1 {
            friendAttendanceNumberLabel.text = String(friendAttendance) + " Bird Of A Feather"
        }
        else {
            friendAttendanceNumberLabel.text = String(friendAttendance) + " Birds Of A Feather"
        }
        
        //set open/closed label 
        if open == true {
            statusImageView.image = UIImage(named: "SignOpen")
        }
        else {
            statusImageView.image = UIImage(named: "SignClosed")
        }
        
        clubNameLabel.text = clubName
        
        //take care of picture scroll view
        if !self.pictureArray.isEmpty {
            self.pictureArray.removeAll()
        }
        self.getPhotosForScrollView()
        self.pictureView.reloadData()
    }
    
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        let del = delegate as! ContainerViewController
        let nav = del.centerNavigationController
        self.pictureArray.removeAll()
        nav.popViewControllerAnimated(true)
    }
    
    func addPhotoPressed(){
        //check to see that the camera is available
        NSLog("ADD PHOTO")
        if UserCurrentClub == self.clubName{
            //allow image to be posted
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                var img = UIImagePickerController()
                img.delegate = self
                img.sourceType = UIImagePickerControllerSourceType.Camera
                img.mediaTypes = [kUTTypeImage]
                img.allowsEditing = false
                self.presentViewController(img, animated: true, completion: nil)
            }
        }
        else {
            let alertView = UIAlertView()
            alertView.title = "Cannot Post Photos From Outside The Club"
            alertView.addButtonWithTitle("Ok")
            alertView.show()
            
        }

    }
    
    func getPhotosForScrollView(){
        
        if !pictureArray.isEmpty {
            pictureArray.removeAll()
        }
        var photoQuery : PFQuery = PFQuery(className: "Image")
        //photoQuery.whereKey("Club_Name", equalTo: currentClubName) //need to set this somehow
        NSLog("club name is \(self.clubName)")
        photoQuery.whereKey("Club", equalTo: self.clubName)
        photoQuery.orderByDescending("createdAt")
        
        
        photoQuery.limit = 10
        
        photoQuery.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                print("Found images:\(objects?.count)")
                for object in (objects as! [PFObject]){
                    print("IN OBJECTS")
                    let photoFile = object["Image_File"] as! PFFile
                    photoFile.getDataInBackgroundWithBlock({ (dataRes:NSData?, error:NSError?) -> Void in
                        if error == nil {
                            let image = UIImage(data: dataRes!)
                            self.pictureArray.append(image!)
                            print("image:\(image)")
                            self.pictureView.reloadData()
                        }
                        
                    })
                }
                
                
            }
            else {
                print(error)
            }
        }
        
    }
    
    
    //MARK Collection View Delegate Methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.pictureArray.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("pictureCell", forIndexPath: indexPath) as! UICollectionViewCell
        
        let photoView : UIImageView = UIImageView(frame: cell.contentView.frame)
        if indexPath.row == 0 {
            let image = UIImage(named: "addPhotoImage")
            photoView.image = image
            let button : UIButton = UIButton(frame: cell.contentView.frame)
            button.backgroundColor = UIColor.clearColor()
            button.setTitle("Button", forState: UIControlState.Normal)
            button.addTarget(self, action: "addPhotoPressed", forControlEvents: UIControlEvents.TouchUpInside)
            cell.contentView.addSubview(button)
        }
        else {
            if pictureArray.isEmpty{
                
            }
            else {
                NSLog("path \(indexPath.row)")
                let image = pictureArray[indexPath.row - 1]
                photoView.image = image
                photoView.backgroundColor = UIColor.blueColor()
            }
        }
        cell.contentView.addSubview(photoView)
        
        return cell
    }
    

    
    //MARK ImagePickerControllerDelegate methods - for using camera/photos
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        //set picked image and send to parse
        if image != nil {
            var imgPFObj : PFObject = PFObject(className: "Image")
            let imageData = UIImageJPEGRepresentation(image, 1.0)
            let imgPFFile = PFFile(name:"image.png", data:imageData)
            imgPFObj["Image_File"] = imgPFFile
            imgPFObj["Club"] = UserCurrentClub
            imgPFObj.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                if success {
                    self.getPhotosForScrollView()
                }
            })
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }
            
        else {
            let alertView = UIAlertView()
            alertView.title = "Error Capturing Image"
            alertView.addButtonWithTitle("OK")
            alertView.show()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    
}