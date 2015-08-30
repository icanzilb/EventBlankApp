//
//  FeedViewController.swift
//  EventBlank
//
//  Created by Marin Todorov on 6/21/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Social
import JSImagePickerController

let kDidPostTweetNotification = "kDidPostTweetNotification"
let kTwitterAuthorizationChangedNotification = "kTwitterAuthorizationChangedNotification"

class FeedViewController: XLSegmentedPagerTabStripViewController, XLPagerTabStripViewControllerDataSource, UIScrollViewDelegate, UIPopoverPresentationControllerDelegate, JSImagePickerViewControllerDelegate {

    @IBOutlet weak var tabControl: UISegmentedControl!
    @IBOutlet weak var btnCompose: UIBarButtonItem!
    
    var popoverController: UIPopoverController?
    var twitterAuthorized = true
    
    var initialized = false
    
    required convenience init(coder aDecoder: NSCoder) {
        self.init()
        self.skipIntermediateViewControllers = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("loaded feed vc view")
        
        //notifications
        observeNotification(kDidReplaceEventFileNotification, selector: "didChangeEventFile")
        observeNotification(kTwitterAuthorizationChangedNotification, selector: "didChangeTwitterAuthorization:")
    }

    deinit {
        //notifications
        observeNotification(kDidReplaceEventFileNotification, selector: nil)
        observeNotification(kTwitterAuthorizationChangedNotification, selector: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !initialized {
            initialized = true
            
            //TODO: why? and what to do if there aren't two days in the conference?
            moveToViewControllerAtIndex(1)
            moveToViewControllerAtIndex(0)
            
            //check if needs to show audience chatter
            if Event.event[Event.twitterChatter] < 1 {
                tabControl.removeSegmentAtIndex(1, animated: false)
            }
        }
    }
    
    override func childViewControllersForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController!) -> [AnyObject]! {
        let newsVC = self.storyboard!.instantiateViewControllerWithIdentifier("NewsNavigationController")! as! TabStripNavigationController
        let chatterVC = self.storyboard!.instantiateViewControllerWithIdentifier("ChatNavigationController")! as! TabStripNavigationController
        if Event.event[Event.twitterChatter] < 1 {
            return [newsVC]
        }
        return [newsVC, chatterVC]
    }

    @IBAction func actionChangeSelectedSegment(sender: AnyObject) {
        if let sender = sender as? UISegmentedControl {
            moveToViewControllerAtIndex(UInt(sender.selectedSegmentIndex))
            btnCompose.enabled = (sender.selectedSegmentIndex == 1)
        }
    }
    
    //MARK: - scroll view methods
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        //super.scrollViewDidEndDecelerating(scrollView)
        if Event.event[Event.twitterChatter] < 1 {
            return
        }
        let currentPage = lround(Double(scrollView.contentOffset.x / scrollView.frame.size.width))
        tabControl.selectedSegmentIndex = currentPage
        btnCompose.enabled = twitterAuthorized && (tabControl.selectedSegmentIndex == 1)
    }
    
    //notifications
    func didChangeEventFile() {
        reloadPagerTabStripView()
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func actionNew(sender: AnyObject) {
        
        if !twitterAuthorized {
            return
        }
        
        let storyboard = view.window!.rootViewController!.storyboard!
        let contentViewController = storyboard.instantiateViewControllerWithIdentifier("TweetComposeViewController") as! TweetComposeViewController
        
        contentViewController.modalPresentationStyle = .Popover
        
        var detailPopover: UIPopoverPresentationController = contentViewController.popoverPresentationController!
        detailPopover.delegate = self
        detailPopover.barButtonItem = sender as! UIBarButtonItem
        detailPopover.permittedArrowDirections = .Any
        
        contentViewController.preferredContentSize = CGSize(width: 230, height: 80)
        contentViewController.buttonCallback = {hasImage in
            self.dismissViewControllerAnimated(true, completion: {
                hasImage ? self.selectTweetImage() : self.composeTweet()
            })
        }
        presentViewController(contentViewController, animated: true, completion:nil)
    }
    
    func composeTweet(image: UIImage? = nil) {
        let tag = Event.event[Event.twitterTag]!.hasPrefix("#") ? Event.event[Event.twitterTag]! : "#\(Event.event[Event.twitterTag]!)"
        tweet("\(tag) ", image: image, urlString: nil, completion: {success in
            if success {
                self.notification(kDidPostTweetNotification, object: nil)
            }
        })
    }
    
    func selectTweetImage() {
        let imagePicker = JSImagePickerViewController()
        imagePicker.delegate = self
        imagePicker.showImagePickerInController(view.window!.rootViewController!, animated: true)
    }

    func imagePickerDidSelectImage(image: UIImage!) {
        delay(seconds: 0.1, {
            self.composeTweet(image: image)
        })
    }

    // Delegate method to allow popovers to be presented in narrow horizontal contexts not fullscreen
    internal func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }

    func didChangeTwitterAuthorization(notification: NSNotification) {
        if let authorized = notification.userInfo?["object"] as? Bool {
            twitterAuthorized = authorized
        }
        btnCompose.enabled = twitterAuthorized && (tabControl.selectedSegmentIndex == 1)
        btnCompose.tintColor = btnCompose.enabled ? nil : UIColor.darkGrayColor()
    }
    
}
