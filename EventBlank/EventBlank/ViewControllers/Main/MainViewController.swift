//
//  MainViewController.swift
//  EventBlank
//
//  Created by Marin Todorov on 8/29/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController {

    @IBOutlet weak var lblConfName: UILabel!
    @IBOutlet weak var lblConfSubtitle: UILabel!
    @IBOutlet weak var imgConfLogo: UIImageView!
    
    @IBOutlet weak var lblRightNow: UILabel!
    
    @IBOutlet weak var lblOrganizer: UILabel!
    
    var nowTap: UITapGestureRecognizer!
    let rightNow = RightNowModel()
  
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        //attach tap to right now info
        lblRightNow.userInteractionEnabled = true

        nowTap = UITapGestureRecognizer(target: self, action: "didTapRightNow:")
        lblRightNow.addGestureRecognizer(nowTap)
        
        observeNotification(kDidReplaceEventFileNotification, selector: "didChangeFile")
    }

    deinit {
        observeNotification(kDidReplaceEventFileNotification, selector: nil)
    }
    
    var linkToSchedule = false
    
    func didChangeFile() {
        setupUI(false)
    }
    
    func setupUI(scheduleAnotherReload: Bool = true) {
        
        let event = EventData.defaultEvent
        print("event \(event)")
        
        let primaryColor = UIColor(hexString: event.mainColor)

        //logo
        imgConfLogo.image = event.logo.imageValue

        //name
        lblConfName.textColor = primaryColor
        lblConfName.text = event.title

        //subtitle
        lblConfSubtitle.textColor = UIColor.grayColor()
        lblConfSubtitle.text = event.subtitle
        
        //organizer
        lblOrganizer.textColor = UIColor.grayColor()
        lblOrganizer.text = "organized by \n" + event.organizer
        
        //right now
        lblRightNow.textColor = primaryColor
        let (nowText, shouldLinkToSchedule) = rightNow.current(event)
        lblRightNow.text = nowText
        linkToSchedule = shouldLinkToSchedule
        
        if scheduleAnotherReload {
            delay(seconds: 1 * 60, completion: {
                //refresh the right now info
                self.setupUI()
            })
        }
    }
    
    func didTapRightNow(tap: UITapGestureRecognizer) {
        
        if !linkToSchedule {
            lblRightNow.transform = CGAffineTransformMakeScale(0.33, 0.33)
            UIView.animateWithDuration(1.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0, options: .AllowUserInteraction, animations: {
                self.lblRightNow.transform = CGAffineTransformIdentity
            }, completion: nil)
            return
        }
        
        //switch to schedule
        let tabController = view.window!.rootViewController as! UITabBarController
        tabController.selectedIndex = EventBlankTabIndex.Schedule.rawValue
        
        //emit "show current sessions" notification
        delay(seconds: 0.25, completion: {
            //allow for the schedule view controller to build up if 1st display
            self.notification(kShowCurrentSessionNotification, object: nil)
        })
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
}

