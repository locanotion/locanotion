//
//  ParseRetreival.swift
//  Locanotion
//
//  Created by William Bertrand on 5/9/15.
//  Copyright (c) 2015 Locanotion. All rights reserved.
//

import Foundation

class ParseRetreival : NSObject {
    
    ///Array of tuples:(string,int) to hold club, num people
    var clubInfoArray = [String: Int]()
    //another array to hold just friend attendence counts
    var friendsInfoArray = [String: Int]()
    
    func fillArraysBlank() {
        for club in CLUB_NAMES {
            friendsInfoArray[club] = 0
            clubInfoArray[club] = 0
        }
    }
    
    
    func getAllInfo(){
        for club in CLUB_NAMES {
            self.clubInfoArray[club] = 0
        }
        // self.clubInfoArray["Migrating"] = 0
        var clubQuery = PFQuery(className: "Club")
        clubQuery.findObjectsInBackgroundWithBlock { (result:[AnyObject]?, error:NSError?) -> Void in
            let clubArray = result as! [PFObject]
            for club in clubArray {
                let clubName = club["Club_Name"] as! String
                let attendance = club["Attendance"] as! Int
                self.clubInfoArray[clubName] = attendance
            }
            self.getFriendsClubInfo()
        }
        
    }
    
    func getFriendsClubInfo(){
        for club1 in CLUB_NAMES {
            self.friendsInfoArray[club1] = 0
        }
        
        //migrating
        self.friendsInfoArray["Migrating"] = 0
        //cerate and call query to find all user's friends at clubs
        
        NSLog("Before Query")
        var friendshipQuery: PFQuery = PFQuery(className: "Activity")
        friendshipQuery.whereKey("Type", equalTo: "Friend")
        friendshipQuery.whereKey("From_User", equalTo: PFUser.currentUser()!)//current user
        friendshipQuery.findObjectsInBackgroundWithBlock { (result:[AnyObject]?, error:NSError?) -> Void in
            if error != nil{
                NSLog("Error with friendship query")
            }
            NSLog("no error \(result?.count)")
            //result is array of activity objects
            let resultArray = result as! [PFObject]
            NSLog("res array: \(resultArray.count)")
            for res in resultArray {
                let friendId = res["To_User"] as! PFUser
                
                var friendQuery = PFUser.query()
                friendQuery?.getObjectInBackgroundWithId(friendId.objectId!, block: { (object:PFObject?, error:NSError?) -> Void in
                    if object != nil {
                        let user = object as! PFUser
                        let location = user["LocationName"] as! String
                        self.friendsInfoArray[location] = self.friendsInfoArray[location]! + 1
                    }
                    
                })
            }
            //Add anything needed to be done after queries have finished right here
            
        }
    }
    
    
    
}
