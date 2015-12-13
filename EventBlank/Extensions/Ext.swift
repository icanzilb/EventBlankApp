//
//  Ext.swift
//  EventBlank
//
//  Created by Marin Todorov on 3/12/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import Foundation
import UIKit

func delay(seconds seconds: Double, completion:()->Void) {
    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
    
    dispatch_after(popTime, dispatch_get_main_queue()) {
        completion()
    }
}

func backgroundQueue(block: ()->Void, completion:(()->Void)? = nil) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
        block()
        if let completion = completion {
            mainQueue(completion)
        }
    })
}

func mainQueue(block: ()->Void) {
    dispatch_async(dispatch_get_main_queue(), block)
}