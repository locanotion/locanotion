//
//  CenterViewController.swift
//  Locanotion
//
//  Created by William Bertrand on 5/2/15.
//  Copyright (c) 2015 Locanotion. All rights reserved.
//
import UIKit

@objc
protocol CenterViewControllerDelegate {
    optional func toggleLeftPanel()
    optional func toggleRightPanel()
    optional func collapseSidePanels()
}

class CenterViewController: UIViewController {
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var creatorLabel: UILabel!
    
    var delegate: CenterViewControllerDelegate?
    
    var currentPage : String = ""
    
    let MAP_PAGE = "View Map"
    let FRIEND_PAGE = "View Friends"
    let CLUB_PAGE = "View Clubs"
    let HOME = "Home"
    var firstPush = true
    
    // MARK: Button actions
    
    @IBAction func lefttapped(sender: AnyObject) {
        print("left")
        delegate?.toggleLeftPanel?()
    }
    
    @IBAction func rightTapped(sender: AnyObject) {
    
    }
    
}

extension CenterViewController: SidePanelViewControllerDelegate {
    
    func navItemSelected(item: NavItem) {
        NSLog("SELECTED!!!!")
        NSLog("cur \(currentPage)")
        NSLog("item \(item.title)")
        delegate?.collapseSidePanels?()
        
        let del = delegate as! ContainerViewController
        let nav = del.centerNavigationController
       
        if !nav.topViewController.isKindOfClass(ViewController) {
            if item.title != currentPage {
                nav.popViewControllerAnimated(false)
            }
        }
        
        if item.title == "View Map"{
            if currentPage != MAP_PAGE {
                currentPage = MAP_PAGE
                var newMap = del.getNewMapPage() as MapPageViewController
                nav.pushViewController(newMap, animated: false)
            }
            
        }
        else if item.title == "View Friends"{
            if currentPage != FRIEND_PAGE {
                currentPage = FRIEND_PAGE
                nav.pushViewController(del.friendsViewController, animated: false)
            }
        }
        else if item.title == "View Clubs"{
            if currentPage != CLUB_PAGE{
                currentPage = CLUB_PAGE
                nav.pushViewController(del.clubsViewController, animated: false)
            }
        }
        else if item.title == "Home"{
            if currentPage != HOME{
                currentPage = HOME
                //nav.popToViewController(del.viewController, animated: true)
            }
        }
        else if item.title == "Log Out" {
            //clear all variables and data that should be renewed for next user
            nav.popViewControllerAnimated(true)
            if !nav.topViewController.isKindOfClass(ViewController){
                nav.popViewControllerAnimated(true)
            }
            del.viewController.loginButtonDidLogOut(del.viewController.loginButton)
        }
    }
}