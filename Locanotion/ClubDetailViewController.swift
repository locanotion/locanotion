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
    var totalAttendanceNumberLabel : UILabel!
    var friendAttendanceNumberLabel : UILabel!
    var pictureView : UICollectionView!
    var pictureArray : Array<UIImage> = Array()
    
    //Properties for side-panel menu
    var delegate: CenterViewControllerDelegate?
    
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
        self.getPhotosForScrollView()
        pictureView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(pictureView)
        
        
        //set up AV capturing
        //captureSession.sessionPreset = AVCaptureSessionPresetMedium
        //let devices = AVCaptureDevice.devices()
        /*for device in devices {
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the back camera
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                }
            }
        }*/
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        NSLog("WillAppear")
        clubNameLabel.text = clubName
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
            let image = pictureArray[indexPath.row - 1]
            photoView.image = image
            photoView.backgroundColor = UIColor.blueColor()
        }
        cell.contentView.addSubview(photoView)
        
        return cell
    }
    
    /*func beginCaptureSession(){
        var err : NSError? = nil
        captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &err))
        
        if err != nil {
            println("error with camera: \(err?.localizedDescription)")
            
        }
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.view.layer.addSublayer(previewLayer)
        previewLayer?.frame = self.view.layer.frame
        captureSession.startRunning()
    }*/
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        //set picked image and send to parse
        if image != nil {
            var imgPFObj : PFObject = PFObject(className: "Image")
            let imageData = UIImageJPEGRepresentation(image, 1.0)
            let imgPFFile = PFFile(name:"image.png", data:imageData)
            imgPFObj["Image_File"] = imgPFFile
            imgPFObj["Club"] = UserCurrentClub
            imgPFObj.saveInBackground()
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
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        let del = delegate as! ContainerViewController
        let nav = del.centerNavigationController
        nav.popViewControllerAnimated(true)
    }
    
    func addPhotoPressed(){
        //check to see that the camera is available
        
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
        /*
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            var img = UIImagePickerController()
            img.delegate = self
            img.sourceType = UIImagePickerControllerSourceType.Camera
            img.mediaTypes = [kUTTypeImage]
            img.allowsEditing = false
            self.presentViewController(img, animated: true, completion: nil)
        }*/
        
       
    }
    
    func getPhotosForScrollView(){
        var photoQuery : PFQuery = PFQuery(className: "Image")
        //photoQuery.whereKey("Club_Name", equalTo: currentClubName) //need to set this somehow
        photoQuery.whereKey("Club", equalTo: self.clubName)
        photoQuery.orderByDescending("createdAt")
        
        
        photoQuery.limit = 10
        
        photoQuery.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                print("Found images:\(objects?.count)")
                for object in (objects as! [PFObject]){
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
}