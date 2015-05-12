//
//  SidePanelViewController.swift
//  Locanotion
//
//  Created by William Bertrand on 5/1/15.
//  Copyright (c) 2015 Locanotion. All rights reserved.
//

import Foundation
import UIKit

@objc
protocol SidePanelViewControllerDelegate {
    func navItemSelected(item: NavItem)
}

class SidePanelViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    var loginButton : FBSDKLoginButton!
    var items: Array<NavItem>!
    @IBOutlet var tableView : UITableView!
    
    var delegate: SidePanelViewControllerDelegate?
    
    struct TableView {
        struct CellIdentifiers {
            static let ItemCell = "ItemCell"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.reloadData()
        
        loginButton = FBSDKLoginButton(frame: CGRect(x: 10, y: self.tableView.frame.height + 50, width: 120, height: 30))
        loginButton.delegate = self
        self.view.addSubview(loginButton)
    }
    
    //mark login button delegate methods
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        let del = delegate as! CenterViewController
        let delDel = del.delegate as! ContainerViewController
        let nav = delDel.centerNavigationController
        delDel.viewController.locationManager.stopUpdatingLocation()
        nav.popToRootViewControllerAnimated(false)
    }
    
    
    
}

// MARK: Table View Data Source

extension SidePanelViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier(TableView.CellIdentifiers.ItemCell, forIndexPath: indexPath) as! ItemCell
            cell.configureForItem(items[indexPath.row])
            return cell
        
        
    }
    
    
}

// Mark: Table View Delegate

extension SidePanelViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedItem = items[indexPath.row]
        delegate?.navItemSelected(selectedItem)
    }
    
}

class ItemCell: UITableViewCell {
    
    //@IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var imageNameLabel: UILabel!
    
    func configureForItem(item: NavItem) {
        
        if item.title == "Log Out" {
            var button : UIButton = UIButton(frame: CGRect(x: 10, y: 0, width: 100, height: contentView.frame.height - 1))
            button.layer.cornerRadius = 3
            button.backgroundColor = DIM_RED
            button.setTitle("Log Out", forState: UIControlState.Normal)
            button.titleLabel?.textColor = UIColor.whiteColor()
            contentView.addSubview(button)
        }
        else {
            //itemImageView.image = item.image
            imageNameLabel.text = item.title
            imageNameLabel.font = UIFont(name: "Avenir Next", size: 25)
        }
    }
}