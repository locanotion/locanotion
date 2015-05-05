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
    
    let MAP_PAGE = "Map Page"
    let FRIEND_PAGE = "Friend Page"
    let CLUB_PAGE = "Club Page"
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
        delegate?.collapseSidePanels?()
        
        let del = delegate as! ContainerViewController
        let nav = del.centerNavigationController
        if firstPush == true {
            firstPush = false
            //nav.pushViewController(del.hideView, animated: false)
        }
        
        if nav.topViewController.isKindOfClass(ViewFriendsViewController) {
            var vfc = nav.topViewController as! ViewFriendsViewController
            vfc.emptyArrays()
        }
        
        if !nav.topViewController.isKindOfClass(ViewController) {
            nav.popViewControllerAnimated(true)
        }
        
        if item.title == "View Map"{
            if currentPage != MAP_PAGE {
                currentPage = MAP_PAGE
                nav.pushViewController(del.mapPageViewController, animated: true)
            }
            
        }
        else if item.title == "View Friends"{
            if currentPage != FRIEND_PAGE {
                currentPage = FRIEND_PAGE
                
                nav.pushViewController(del.friendsViewController, animated: true)
                
                
            }
        }
        else if item.title == "View Clubs"{
            if currentPage != CLUB_PAGE{
                currentPage = CLUB_PAGE
                nav.pushViewController(del.clubsViewController, animated: true)
            }
        }
        else if item.title == "Home"{
            if currentPage != HOME{
                currentPage = HOME
                //nav.popToViewController(del.viewController, animated: true)
            }
        }
    }
}