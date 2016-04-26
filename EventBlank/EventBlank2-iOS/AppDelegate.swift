//
//  AppDelegate.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 2/19/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import UIKit
import RealmSwift
import MAThemeKit

extension UIApplication {
    static var controller: AppController {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).appController
    }
    
    static var interactor: Interactor {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).appController.interactor
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appController = AppController()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        setupUI()
        return true
    }
}

extension AppDelegate {
    func setupUI() {
        window?.backgroundColor = UIColor.whiteColor()
        
        let event = EventData.defaultEvent
        let primaryColor = event.mainColor
        //let secondaryColor = event.secondaryColor
        
        MAThemeKit.customizeNavigationBarColor(primaryColor, textColor: UIColor.whiteColor(), buttonColor: UIColor.whiteColor())
        MAThemeKit.customizeButtonColor(primaryColor)
        MAThemeKit.customizeSwitchOnColor(primaryColor)
        MAThemeKit.customizeSearchBarColor(primaryColor, buttonTintColor: UIColor.whiteColor())
        MAThemeKit.customizeActivityIndicatorColor(primaryColor)
        MAThemeKit.customizeSegmentedControlWithMainColor(UIColor.whiteColor(), secondaryColor: primaryColor)
        MAThemeKit.customizeSliderColor(primaryColor)
        MAThemeKit.customizePageControlCurrentPageColor(primaryColor)
        MAThemeKit.customizeTabBarColor(UIColor.whiteColor().mixWithColor(primaryColor, weight: 0.025), textColor: primaryColor)
    }
}