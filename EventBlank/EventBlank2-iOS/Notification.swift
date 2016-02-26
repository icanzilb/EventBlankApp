//
//  Notification.swift
//  EventBlank
//
//  Created by Marin Todorov on 6/22/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import Foundation

extension NSObject {
    
    func observeNotification(name: String, selector: Selector?) {
        if let selector = selector {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: name, object: nil)
        } else {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: name, object: nil)
        }
    }
    
    func notification(name: String, object: AnyObject? = nil) {
        if let dict = object as? NSDictionary {
            NSNotificationCenter.defaultCenter().postNotificationName(name, object: nil, userInfo: dict as [NSObject: AnyObject])
        } else if let object: AnyObject = object {
            NSNotificationCenter.defaultCenter().postNotificationName(name, object: nil, userInfo: ["object": object])
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName(name, object: nil, userInfo: nil)
        }
    }
    
}