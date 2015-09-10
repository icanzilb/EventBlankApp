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
import KHTabPagerViewController

let kDidPostTweetNotification = "kDidPostTweetNotification"
let kTwitterAuthorizationChangedNotification = "kTwitterAuthorizationChangedNotification"

//TODO: ALL the pager code was added in a hurry for iOS9, need to clean up this mess

class FeedViewController: KHTabPagerViewController, KHTabPagerDataSource, UIScrollViewDelegate, UIPopoverPresentationControllerDelegate, JSImagePickerViewControllerDelegate {

    var popoverController: UIPopoverController?
    var twitterAuthorized = true
    
    var initialized = false
    
    let btnCompose = UIButton.buttonWithType(.Custom) as! UIButton
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("loaded feed vc view")
        
        dataSource = self
        delegate = self
        
        btnCompose.hidden = true
        
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
            reloadData()
        }
    }
    
    override func reloadData() {
        super.reloadData()

        let header = valueForKey("header") as! KHTabScrollView // you made me to, the header view is not public
        
        //add compose button
        btnCompose.setImage(UIImage(named: "compose")!, forState: .Normal)
        btnCompose.setTitle(nil, forState: .Normal)
        btnCompose.tintColor = UIColor.whiteColor()
        btnCompose.frame = CGRect(
            x: header.frame.size.width - 50,
            y: 20,
            width: 46,
            height: 46)
        btnCompose.addTarget(self, action: "actionNew:", forControlEvents: .TouchUpInside)
        updateComposeButtonHidden()
        header.addSubview(btnCompose)
    }
    
    //notifications
    func didChangeEventFile() {
        reloadData()
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
        detailPopover.sourceView = sender as! UIButton
        detailPopover.sourceRect = CGRect(x: 20, y: 30, width: 10, height: 10)
        detailPopover.permittedArrowDirections = .Up
        
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
                mainQueue({
                    let message = self.alert("Tweet posted successfully. It could take up to a minute to see it in the stream.", buttons: ["Close"], completion: nil)
                    delay(seconds: 2.0, {
                        message.dismissViewControllerAnimated(true, completion: nil)
                    })
                })
            }
        })
    }
    
    func selectTweetImage() {
        let imagePicker = JSImagePickerViewController()
        imagePicker.delegate = self
        imagePicker.showImagePickerInController(view.window!.rootViewController!, animated: true)
    }

    func imagePickerDidSelectImage(image: UIImage!) {
        delay(seconds: 0.5, {
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
    }
    
    func updateComposeButtonHidden() {
        let showBtn = (twitterAuthorized && (selectedIndex() == 1))
        
        if showBtn && btnCompose.hidden {
            btnCompose.center.x -= 10
            btnCompose.hidden = false
            btnCompose.alpha = 0
            UIView.animateWithDuration(0.33, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
                self.btnCompose.center.x += 10
                self.btnCompose.alpha = 1
            }, completion: nil)
        } else if !showBtn && btnCompose.hidden == false {
            UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
                self.btnCompose.center.x -= 5
                self.btnCompose.alpha = 0
            }, completion: {_ in
                self.btnCompose.center.x += 5
                self.btnCompose.alpha = 1
                self.btnCompose.hidden = true
            })
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}