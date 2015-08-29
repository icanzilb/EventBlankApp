//
//  MainViewController.swift
//  EventBlank
//
//  Created by Marin Todorov on 8/29/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import SQLite

class MainViewController: UIViewController {

    @IBOutlet weak var lblConfName: UILabel!
    @IBOutlet weak var lblConfSubtitle: UILabel!
    @IBOutlet weak var imgConfLogo: UIImageView!
    
    @IBOutlet weak var lblRightNow: UILabel!
    
    @IBOutlet weak var lblOrganizer: UILabel!
    @IBOutlet weak var lblHashTag: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    func setupUI() {
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
        lblRightNow.text = rightNowText(event)
    }
    
    func rightNowText(event: Row) -> String {
        
        let now = Int(NSDate().timeIntervalSince1970)
        
        if now < event[Event.start] {
            //before the event
            
            let remaining = event[Event.start] - now
            let days = Int(ceil(Double(remaining) / Double(24 * 60 * 60)))
            
            if days > 1 {
                return "The event starts in \(days) days!"
            } else {
                return "Starting within hours, get ready!"
            }
            
        } else if now > event[Event.start] && now < event[Event.end] {
            //during the event
            
            return "The even is ongoing"
            
        } else {
            //after the event
            return "The event has already finished. You can still browse the speaker and sessions data in the app."
        }
    }
    
    
}

