//
//  ContainerViewController.swift
//  Locanotion
//
//  Created by William Bertrand on 5/1/15.
//  Copyright (c) 2015 Locanotion. All rights reserved.
//

import UIKit
import QuartzCore

//keep track of which slide out state the container view is in
enum SlideOutState {
    case BothCollapsed
    case LeftPanelExpanded
    case RightPanelExpanded
}



class ContainerViewController: UIViewController, CenterViewControllerDelegate {
    
    var centerNavigationController: UINavigationController!
    var centerViewController: CenterViewController!
    
    //View Controllers for the app
    var viewController: ViewController!
    var mapPageViewController : MapPageViewController!
    var friendsViewController : ViewFriendsViewController!
    var clubsViewController : ViewClubsViewController!
    var signInViewController : SignInPageViewController!
    var hideView : HideViewController!
    
    //detail view controller
    var clubDetailViewController : ClubDetailViewController!
    
    //keep track of which view controller is currently on top
    
    
    
    
    var currentState: SlideOutState = .BothCollapsed {
        didSet {
            let shouldShowShadow = currentState != .BothCollapsed
            showShadowForCenterViewController(shouldShowShadow)
        }
    }
    var leftViewController: SidePanelViewController?
    
    let centerPanelExpandedOffset: CGFloat = 200
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centerViewController = UIStoryboard.centerViewController()
        centerViewController.delegate = self
        
        
        //instantiate the views for each page
        friendsViewController = UIStoryboard.FriendsPageView()
        clubsViewController = UIStoryboard.ClubsPageView()
        mapPageViewController = UIStoryboard.MapPageView()
        viewController = UIStoryboard.viewController()
        signInViewController = UIStoryboard.signInPage()
        clubDetailViewController = UIStoryboard.clubDetailView()
        hideView = UIStoryboard.hideView()
        viewController.delegate = self
        mapPageViewController.delegate = self
        friendsViewController.delegate = self
        clubsViewController.delegate = self
        signInViewController.delegate = self
        clubDetailViewController.delegate = self
        
        
        // wrap the centerViewController in a navigation controller, so we can push views to it
        // and display bar button items in the navigation bar
        centerNavigationController = UINavigationController(rootViewController: signInViewController)
        centerNavigationController.setNavigationBarHidden(true, animated: false)
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)
        
        centerNavigationController.didMoveToParentViewController(self)
        
    }
    
    
    //CenterViewController delegate methods
    func toggleLeftPanel() {
        let notAlreadyExpanded = (currentState != .LeftPanelExpanded)
        
        if notAlreadyExpanded {
            addLeftPanelViewController()
        }
        
        animateLeftPanel(shouldExpand: notAlreadyExpanded)
    }
    
    func toggleRightPanel() {
    }
    
    func collapseSidePanels() {
        switch (currentState) {
        case .RightPanelExpanded:
            toggleRightPanel()
        case .LeftPanelExpanded:
            toggleLeftPanel()
        default:
            break
        }
    }
    
    func addLeftPanelViewController() {
        print("adding left")
        if (leftViewController == nil) {
            leftViewController = UIStoryboard.leftViewController()
            leftViewController!.delegate =  centerViewController
            leftViewController!.items = NavItem.allItems()
            print(leftViewController!.items.count)
            addChildSidePanelController(leftViewController!)
        }
    }
    
    func addChildSidePanelController(sidePanelController: SidePanelViewController) {
        view.insertSubview(sidePanelController.view, atIndex: 0)
        
        addChildViewController(sidePanelController)
        sidePanelController.didMoveToParentViewController(self)
    }
    
    
    func addRightPanelViewController() {
    }
    
    func animateLeftPanel(#shouldExpand: Bool) {
        if (shouldExpand) {
            currentState = .LeftPanelExpanded
            
            animateCenterPanelXPosition(targetPosition: CGRectGetWidth(centerNavigationController.view.frame) - centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.currentState = .BothCollapsed
                
                self.leftViewController!.view.removeFromSuperview()
                self.leftViewController = nil;
            }
        }
    }
    
    func animateCenterPanelXPosition(#targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.centerNavigationController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func animateRightPanel(#shouldExpand: Bool) {
    }
    
    
    func showShadowForCenterViewController(shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            centerNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            centerNavigationController.view.layer.shadowOpacity = 0.0
        }
    }
    
}

// MARK: CenterViewController delegate

//extension ContainerViewController: CenterViewControllerDelegate {
    
    
    
//}



private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
    
    class func leftViewController() -> SidePanelViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("LeftViewController") as? SidePanelViewController
    }
    
    class func rightViewController() -> SidePanelViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("RightViewController") as? SidePanelViewController
    }
    
    class func centerViewController() -> CenterViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("CenterViewController") as? CenterViewController
    }
    
    class func viewController() -> ViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("ViewController") as? ViewController
    }
    
    class func MapPageView() -> MapPageViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("MapPageViewController") as? MapPageViewController
    }
    
    class func FriendsPageView() -> ViewFriendsViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("ViewFriendsViewController") as? ViewFriendsViewController
    }
    
    class func ClubsPageView() -> ViewClubsViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("ViewClubsViewController") as? ViewClubsViewController
    }
    
    class func signInPage() -> SignInPageViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("SignInPageViewController") as? SignInPageViewController
    }
    
    class func clubDetailView() -> ClubDetailViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("ClubDetailViewController") as? ClubDetailViewController
    }
    
    class func hideView() -> HideViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("HideViewController") as? HideViewController
    }
    
    
    
}