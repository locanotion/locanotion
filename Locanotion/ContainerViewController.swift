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
    var coverView : UIView!
    var centerNavigationController: UINavigationController! //instead of navigation controller, use a refrence to a single view controller
    var centerViewController: CenterViewController!
    
    //View Controllers for the app
    var viewController: ViewController!
    var mapPageViewController : MapPageViewController!
    var friendsViewController : ViewFriendsViewController!
    var friendsDetailViewController : FriendDetailViewControlelr!
    var clubsViewController : ViewClubsViewController!
    var signInViewController : SignInPageViewController!
    var hideView : HideViewController!
    
    //detail view controller
    var clubDetailViewController : ClubDetailViewController!
    
    //keep track of which view controller is currently on top
    
    
    //
    
    var currentState: SlideOutState = .BothCollapsed {
        didSet {
            let shouldShowShadow = currentState != .BothCollapsed
            showShadowForCenterViewController(shouldShowShadow)
        }
    }
    var leftViewController: SidePanelViewController?
    
    var centerPanelExpandedOffset: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centerPanelExpandedOffset = self.view.frame.width * 1 / 5
        centerViewController = UIStoryboard.centerViewController()
        centerViewController.delegate = self
        
        
        //instantiate the views for each page
        friendsViewController = UIStoryboard.FriendsPageView()
        friendsDetailViewController = UIStoryboard.friendDetailView()
        clubsViewController = UIStoryboard.ClubsPageView()
        mapPageViewController = UIStoryboard.MapPageView()
        viewController = UIStoryboard.viewController()
        signInViewController = UIStoryboard.signInPage()
        clubDetailViewController = UIStoryboard.clubDetailView()
        hideView = UIStoryboard.hideView()
        friendsDetailViewController.delegate = self
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
        
        
        //swipe rec
        //let panGestureRec = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        //centerNavigationController.view.addGestureRecognizer(panGestureRec)
        
        coverView = UIView(frame: CGRect(x: 0, y: 50, width: centerNavigationController.view.frame.width, height: centerNavigationController.view.frame.height - 50))
        
    }
    
    
    func getNewMapPage() -> MapPageViewController {
        var newMapPageViewController = UIStoryboard.MapPageView()
        newMapPageViewController?.delegate = self
        return newMapPageViewController!
    }
    
    
    //CenterViewController delegate methods
    func toggleLeftPanel() {
        let notAlreadyExpanded = (currentState != .LeftPanelExpanded)
        
        if notAlreadyExpanded {
            addLeftPanelViewController()
            coverView.backgroundColor = UIColor.clearColor()
            centerNavigationController.view.addSubview(coverView)
        }
        else {
            coverView.removeFromSuperview()
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
        if (leftViewController == nil) {
            leftViewController = UIStoryboard.leftViewController()
            leftViewController!.delegate =  centerViewController
            leftViewController!.items = NavItem.allItems()
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
            centerNavigationController.view.addSubview(coverView)
            currentState = .LeftPanelExpanded
            animateCenterPanelXPosition(targetPosition: CGRectGetWidth(centerNavigationController.view.frame) - centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.currentState = .BothCollapsed
                self.coverView.removeFromSuperview()
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
    
    class func friendDetailView() -> FriendDetailViewControlelr? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("FriendDetailViewController") as? FriendDetailViewControlelr
    }
    
    
    
}

extension ContainerViewController: UIGestureRecognizerDelegate{
    func handlePanGesture(recognizer: UIPanGestureRecognizer){
        let gestureIsDraggingFromLeftToRight = (recognizer.velocityInView(view).x > 0)
        
        switch(recognizer.state) {
        case .Began:
            if (currentState == .BothCollapsed) {
                if (gestureIsDraggingFromLeftToRight) {
                    addLeftPanelViewController()
                } else {
                    //addRightPanelViewController()
                }
                
                showShadowForCenterViewController(true)
            }
        case .Changed:
            if gestureIsDraggingFromLeftToRight {
                recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translationInView(view).x
                recognizer.setTranslation(CGPointZero, inView: view)
            }
            else {
                if currentState == .LeftPanelExpanded{
                    recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translationInView(view).x
                    recognizer.setTranslation(CGPointZero, inView: view)
                }
            }
        case .Ended:
            if (leftViewController != nil) {
                // animate the side panel open or closed based on whether the view has moved more or less than halfway
                let hasMovedGreaterThanHalfway = recognizer.view!.center.x > view.bounds.size.width
                animateLeftPanel(shouldExpand: hasMovedGreaterThanHalfway)
            }
            
        default:
            break
        }
    }
}