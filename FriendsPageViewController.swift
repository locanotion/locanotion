//
//  FriendsPageViewController.swift
//  Locanotion
//
//  Created by William Bertrand on 3/27/15.
//  Copyright (c) 2015 Locanotion. All rights reserved.
//

import Foundation
import UIKit

class FriendsPageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var friendsTableView: UITableView!
    var friends = []
    let textCellIdentifier = "FriendCell"
    
    override func viewWillAppear(animated: Bool) {
        //get the user's
        var user = PFUser.currentUser()
        if user == nil {
            //display some error message
        }
        
        var query = PFUser.query()
        friends = query.findObjects()
        
        
        
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
        return friends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as FriendViewTableCell
        
        let row = indexPath.row
        let cellUser = friends[row] as PFUser
        let loc = cellUser["LocationName"] as String
        
        cell.nameLabel.text = cellUser.username
        cell.locLabel.text = loc
        //cell.locImageView.image = UIImage(named: "ViewOnMap")
        return cell
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        friendsTableView.deselectRowAtIndexPath(indexPath, animated: true)
        let row = indexPath.row
        
    }
    
}


