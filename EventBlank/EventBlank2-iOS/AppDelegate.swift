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
    let realmProvider = RealmProvider()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }
}