//
//  MainViewController.swift
//  EventBlank
//
//  Created by Marin Todorov on 8/29/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import SQLite

let kShowCurrentSessionNotification = "kShowCurrentSessionNotification"

enum EventBlankTabIndex: Int {
    case Schedule = 1
}

class MainViewController: UIViewController {

    @IBOutlet weak var lblConfName: UILabel!
    @IBOutlet weak var lblConfSubtitle: UILabel!
    @IBOutlet weak var imgConfLogo: UIImageView!
    
    @IBOutlet weak var lblRightNow: UILabel!
    
    @IBOutlet weak var lblOrganizer: UILabel!
    
    var nowTap: UITapGestureRecognizer!
    
    let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.timeStyle = .ShortStyle
        formatter.dateFormat = .None
        return formatter
        }()

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
        setupUI(scheduleAnotherReload: false)
    }
    
    func setupUI(scheduleAnotherReload: Bool = true) {
        let event = (UIApplication.sharedApplication().delegate as! AppDelegate).event
        let primaryColor = UIColor(hexString: event[Event.mainColor])
        
        //logo
        imgConfLogo.image = event[Event.logo]?.imageValue ?? nil
        
        //name
        lblConfName.textColor = primaryColor
        lblConfName.text = event[Event.name]
        
        //subtitle
        lblConfSubtitle.textColor = UIColor.grayColor()
        lblConfSubtitle.text = event[Event.subtitle]
        
        //organizer
        lblOrganizer.textColor = UIColor.grayColor()
        lblOrganizer.text = "organized by \n" + event[Event.organizer]
        
        //right now
        lblRightNow.textColor = primaryColor
        let (nowText, shouldLinkToSchedule) = rightNow(event)
        lblRightNow.text = nowText
        linkToSchedule = shouldLinkToSchedule
        
        if scheduleAnotherReload {
            delay(seconds: 1 * 60, {
                //refresh the right now info
                self.setupUI()
            })
        }
    }
    
    func didTapRightNow(tap: UITapGestureRecognizer) {
        
        if !linkToSchedule {
            lblRightNow.transform = CGAffineTransformMakeScale(0.33, 0.33)
            UIView.animateWithDuration(1.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0, options: nil, animations: {
                self.lblRightNow.transform = CGAffineTransformIdentity
            }, completion: nil)
            return
        }
        
        //switch to schedule
        let tabController = view.window!.rootViewController as! UITabBarController
        tabController.selectedIndex = EventBlankTabIndex.Schedule.rawValue
        
        //emit "show current sessions" notification
        delay(seconds: 0.25, {
            //allow for the schedule view controller to build up if 1st display
            self.notification(kShowCurrentSessionNotification, object: nil)
        })
        
    }
    
    //TODO: need to re-do this one, too much hurry
    func rightNow(event: Row) -> (String, Bool) {
        
        let now = Int(NSDate().timeIntervalSince1970)
        
        if now < event[Event.start] {
            //before the event
            
            let remaining = event[Event.start] - now
            let days = Int(ceil(Double(remaining) / Double(24 * 60 * 60)))
            
            if days > 1 {
                return ("The event starts in \(days) days!", false)
            } else {
                return ("Starting within hours, get ready!", false)
            }
            
        } else if now > event[Event.start] && now < event[Event.end] {
            //during the event
            
            if let nowItems = Schedule().rightNowItems() {
                var result = ""

                if let currentSessions = nowItems.currentSessions {
                    result = "Currently: \(currentSessions.first![Session.title]) by \(currentSessions.first![Speaker.name])"
                }
                
                if let nextSessions = nowItems.nextSessions {
                    let sessionDate = NSDate(timeIntervalSince1970: Double(nextSessions.first![Session.beginTime]))
                    result += "\nNext at \(dateFormatter.stringFromDate(sessionDate)): \(nextSessions.first![Session.title]) by \(nextSessions.first![Speaker.name])"
                }
                
                return (result, true)
            }
            
            return ("The event is ongoing", false)
            
            
        } else {
            //after the event
            return ("The event has already finished. You can still browse the speaker and sessions data in the app.", false)
        }
    }
    
}

