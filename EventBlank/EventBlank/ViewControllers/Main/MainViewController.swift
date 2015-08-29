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
        lblRightNow.text = "Event happening in two days"
    }

}