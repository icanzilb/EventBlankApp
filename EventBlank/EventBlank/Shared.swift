//
//  Shared.swift
//  EventBlank
//
//  Created by Marin Todorov on 9/23/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit

let shortStyleDateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    formatter.timeStyle = .ShortStyle
    formatter.dateFormat = .None
    return formatter
    }()

