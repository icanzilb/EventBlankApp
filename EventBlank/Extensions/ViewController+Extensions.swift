//
//  ViewController+Extensions.swift
//  EventBlank
//
//  Created by Marin Todorov on 7/18/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import Social

extension UIViewController {

    func alert(message: String, buttons: [String] = ["OK"], completion: ((Int)->Void)?) {
        
        let alertVC = UIAlertController(title: "Message",
            message: message,
            preferredStyle: UIAlertControllerStyle.Alert)
        
        for i in 0..<buttons.count {
            let btnAction = UIAlertAction(title: buttons[i], style: UIAlertActionStyle.Default, handler: {_ in
                completion?(i)
            })
            alertVC.addAction(btnAction)
        }
        
        presentViewController(alertVC, animated: true, completion: nil)
    }

    func tweet(message: String, image: UIImage? = nil, urlString: String? = nil, completion: ((Bool)->Void)?) {
        
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            println("twitter available")
            
            let composer = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            composer.setInitialText(message)
            
            if let image = image {
                composer.addImage(image)
            }
            
            if let urlString = urlString, let url = NSURL(string: urlString) {
                composer.addURL(url)
            }
            
            composer.completionHandler = {result in
                composer.dismissViewControllerAnimated(true, completion: nil)
                completion?(result == SLComposeViewControllerResult.Done)
            }
            
            presentViewController(composer, animated: false, completion: nil)
        }

    }
}
