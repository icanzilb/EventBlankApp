//
//  TweetComposeViewController.swift
//  EventBlank
//
//  Created by Marin Todorov on 7/20/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit

class TweetComposeViewController: UIViewController {

    @IBOutlet weak var btnText: UIButton!
    @IBOutlet weak var btnImage: UIButton!
    
    var buttonCallback: ((Bool)->Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnText.setTitle("", forState: .Normal)
        btnImage.setTitle("", forState: .Normal)
        
        btnText.fa(Fa.Font, forState: .Normal)
        btnImage.fa(Fa.Camera, forState: .Normal)
        
        btnText.addTarget(self, action: "actionTweetText:", forControlEvents: .TouchUpInside)
        btnImage.addTarget(self, action: "actionTweetImage:", forControlEvents: .TouchUpInside)
    }

    @IBAction func actionTweetText(sender: AnyObject) {
        buttonCallback?(false)
    }

    @IBAction func actionTweetImage(sender: AnyObject) {
        buttonCallback?(true)
    }
    
}