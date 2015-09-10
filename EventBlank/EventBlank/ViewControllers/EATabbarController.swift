//
//  EATabbarController.swift
//  EventBlank
//
//  Created by Marin Todorov on 9/10/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit

let kTabItemSelectedNotification = "kTabItemSelectedNotification"

class EATabbarController: UITabBarController {
}

extension EATabbarController : UITabBarControllerDelegate {
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!) {
        notification(kTabItemSelectedNotification, object: selectedIndex)
    }
}