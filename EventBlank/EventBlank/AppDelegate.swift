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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  let databaseProvider = DatabaseProvider(filePath: eventDataFileName.inLibrary(), defaultPath: eventDataFileName.inBundle())
  let appDataProvider = DatabaseProvider(filePath: appDataFileName.inLibrary(), defaultPath: appDataFileName.inBundle())

  var event: Row!

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Override point for customization after application launch.

    event = databaseProvider!.database[EventConfig.tableName].first!
    setupUI()
    
    return true
  }

    func setupUI() {
        let primaryColor = UIColor(hexString: event[Event.mainColor])
        let secondaryColor = UIColor(hexString: event[Event.secondaryColor])
        //let ternaryColor = UIColor(hexString: event[Event.ternaryColor])
        
        //println("colors: \([primaryColor, secondaryColor, ternaryColor])")
        
        MAThemeKit.customizeNavigationBarColor(primaryColor, textColor: UIColor.whiteColor(), buttonColor: UIColor.whiteColor())
        MAThemeKit.customizeButtonColor(primaryColor)
        MAThemeKit.customizeSwitchOnColor(primaryColor)
        MAThemeKit.customizeSearchBarColor(primaryColor, buttonTintColor: UIColor.whiteColor())
        MAThemeKit.customizeActivityIndicatorColor(primaryColor)
        MAThemeKit.customizeSegmentedControlWithMainColor(UIColor.whiteColor(), secondaryColor: primaryColor)
        MAThemeKit.customizeSliderColor(primaryColor)
        MAThemeKit.customizePageControlCurrentPageColor(primaryColor)
        
        //MAThemeKit.setupThemeWithPrimaryColor(primaryColor, secondaryColor: secondaryColor, fontName: "HelveticaNeue", lightStatusBar: true)
    }
    
  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
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
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }


}

