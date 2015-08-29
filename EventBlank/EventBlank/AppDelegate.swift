//
//  AppDelegate.swift
//  EventBlank
//
//  Created by Marin Todorov on 3/12/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import SQLite
import MAThemeKit
import DynamicColor

let kDidReplaceEventFileNotification = "kDidReplaceEventFileNotification"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let databaseProvider = DatabaseProvider(
        path: FilePath(inLibrary: eventDataFileName),
        defaultPath: FilePath(inBundle: eventDataFileName),
        preferNewerSourceFile: true)
    
    let appDataProvider = DatabaseProvider(
        path: FilePath(inLibrary: appDataFileName),
        defaultPath: FilePath(inBundle: appDataFileName))
    
    var event: Row!
    var updateManager: UpdateManager?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        loadEventData()
        
        //start the update manager if there's a remote file
        if let updateUrlString = event[Event.updateFileUrl], let updateUrl = NSURL(string: updateUrlString) where !updateUrlString.isEmpty {
            updateManager = UpdateManager(
                filePath: FilePath(inLibrary: eventDataFileName),
                remoteURL: updateUrl, autostart: false)
            
            updateManager!.fileBinder.addAction(didReplaceFile: {success in
                self.databaseProvider!.didChangeSourceFile(success)
                self.loadEventData()
                }, withKey: nil)
            updateManager!.fileBinder.addAction(didReplaceFile: {_ in
                //let observes know data file changed
                self.notification(kDidReplaceEventFileNotification, object: nil)
                }, withKey: nil)
        }
        
        return true
    }
    
    func loadEventData() {
        //load event data
        event = databaseProvider!.database[EventConfig.tableName].first!
        setupUI()
    }
    
    func setupUI() {
        let primaryColor = UIColor(hexString: event[Event.mainColor])
        let secondaryColor = UIColor(hexString: event[Event.secondaryColor])

        MAThemeKit.customizeNavigationBarColor(primaryColor, textColor: UIColor.whiteColor(), buttonColor: UIColor.whiteColor())
        MAThemeKit.customizeButtonColor(primaryColor)
        MAThemeKit.customizeSwitchOnColor(primaryColor)
        MAThemeKit.customizeSearchBarColor(primaryColor, buttonTintColor: UIColor.whiteColor())
        MAThemeKit.customizeActivityIndicatorColor(primaryColor)
        MAThemeKit.customizeSegmentedControlWithMainColor(UIColor.whiteColor(), secondaryColor: primaryColor)
        MAThemeKit.customizeSliderColor(primaryColor)
        MAThemeKit.customizePageControlCurrentPageColor(primaryColor)
        MAThemeKit.customizeTabBarColor(UIColor.whiteColor().mixWithColor(primaryColor, weight: 0.05), textColor: primaryColor)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        if let updateManager = updateManager where updateManager.fileBinder.running {
            updateManager.stop()
        }
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if let updateManager = updateManager where !updateManager.fileBinder.running {
            updateManager.start()
        }
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        updateManager?.stop()
    }
    
}

