//
//  UpdateManager.swift
//  EventBlank
//
//  Created by Marin Todorov on 7/13/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import Foundation
import UIKit

let kPendingUpdateChangedNotification = "kPendingUpdateChangedNotification"

class UpdateManager: NSObject {
    
    var updateCheckInterval = 1.0 * 60.0
    
    var fileBinder: FreshFile
    
    init(filePath path: FilePath, remoteURL: NSURL, autostart: Bool = true) {
        
        fileBinder = FreshFile(localURL: NSURL(fileURLWithPath: path.filePath)!, remoteURL: remoteURL)

        super.init()

        fileBinder.refreshRate = updateCheckInterval

        fileBinder.addAction(willDownloadFile: {info, result in
            dispatch_async(dispatch_get_main_queue(), {
                self.askUserAboutDownloadingUpdate(info, result: result)
            })
        }, withKey: nil)

        if autostart {
            delay(seconds: 1.0, {
                self.start()
            })
        }
    }
    
    func start() {
        self.fileBinder.bind()
    }
    
    func stop() {
        self.fileBinder.unbind()
    }
    
    func askUserAboutDownloadingUpdate(info: FreshInfo, result: (Bool)->Void) {
        println("update manager: will download \(info.etag) update")

        let defaults = NSUserDefaults.standardUserDefaults()
        
        let message = String(format: "Download latest version of the event schedule? This will be a %.2f MB download; if you're on cell data charges may apply.", (info.contentLength!/1_000_000))
        
        let alert = UIAlertController(title: "Allow Download",
            message: message,
            preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let allowAction = UIAlertAction(title: "Allow Download", style: UIAlertActionStyle.Default, handler: {_ in
            defaults.setValue(false, forKey: "isTherePendingUpdate")
            defaults.synchronize()

            self.notification(kPendingUpdateChangedNotification, object: nil)
            
            result(true)
        })
        
        let skipAction = UIAlertAction(title: "Skip Update", style: UIAlertActionStyle.Cancel, handler: {_ in
            defaults.setValue(true, forKey: "isTherePendingUpdate")
            defaults.synchronize()
            
            self.notification(kPendingUpdateChangedNotification, object: nil)
            
            result(false)
        })
        
        alert.addAction(allowAction)
        alert.addAction(skipAction)
        
        //present on tab view controller
        let tabViewController = (UIApplication.sharedApplication().delegate as! AppDelegate).window?.rootViewController as! UITabBarController
        tabViewController.presentViewController(alert, animated: true, completion: nil)
    }
    
    func triggerRefresh() {
        fileBinder.refresh()
    }
}