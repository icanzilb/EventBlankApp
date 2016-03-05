//
//  AppDelegate.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 2/19/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appController = AppController()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }
}

extension UIApplication {
    static var controller: AppController {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).appController
    }
    
    static var interactor: Interactor {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).appController.interactor
    }
}