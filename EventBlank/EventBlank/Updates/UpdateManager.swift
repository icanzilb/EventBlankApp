//
//  UpdateManager.swift
//  EventBlank
//
//  Created by Marin Todorov on 7/13/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import Foundation
import UIKit
import CWStatusBarNotification

class UpdateManager: NSObject {
    
    var updateCheckInterval = 1.0 * 60.0
    
    var fileBinder: FreshFile
    
    var statusBarNotification = CWStatusBarNotification()
    
    init(filePath path: FilePath, remoteURL: NSURL, autostart: Bool = true) {
        
        fileBinder = FreshFile(localURL: NSURL(fileURLWithPath: path.filePath)!, remoteURL: remoteURL)

        super.init()

        fileBinder.refreshRate = updateCheckInterval

        fileBinder.addAction(willDownloadFile: {info, result in
            mainQueue { self.askUserAboutDownloadingUpdate(info, result: result) }
        }, withKey: nil)

        //create the update view
        statusBarNotification.notificationAnimationInStyle = .Top
        statusBarNotification.notificationAnimationOutStyle = .Top
        
        let barView = StatusBarDownloadProgressView()
        let primaryColor = UIColor(hexString: (UIApplication.sharedApplication().delegate as! AppDelegate).event[Event.mainColor])
        barView.backgroundColor = primaryColor

        fileBinder.downloadHandlerWithProgress = {progress in
            mainQueue {
                switch progress {
                case 0.0:
                    self.statusBarNotification.displayNotificationWithView(barView, completion: nil)
                    barView.setProgress(0.0, text: "Starting update download...")
                case 1.0:
                    //download ended hide in 1 second
                    barView.setProgress(1.0, text: "Update downloaded successfully!")
                    delay(seconds: 1.0, {
                        self.statusBarNotification.dismissNotification()
                    })
                default:
                    //show the current progress
                    barView.setProgress(progress, text: String(format: "%.0f%% of the update downloaded", progress * 100.0))
                }
            }
        }
        
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