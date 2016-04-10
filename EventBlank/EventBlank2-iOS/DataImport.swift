//
//  DataImport.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 4/10/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import Foundation
import RealmSwift
import AFDateHelper

func day1(hr: Double) -> NSDate {
    let hour = Int(hr)
    let minutes = Double(hr - Double(hour)) * 100
    
    return NSDate(fromString: "2016-04-25", format: DateFormat.ISO8601(.Date), timeZone: TimeZone.UTC)
        .dateByAddingHours(hour).dateByAddingMinutes(Int(minutes))
}

func day2(hr: Double) -> NSDate {
    return day1(hr).dateByAddingHours(24)
}

func lenInMinutes(d1: NSDate , d2: NSDate) -> Int {
    return Int((d2.timeIntervalSinceReferenceDate - d1.timeIntervalSinceReferenceDate) / 60)
}

class DataImport {}

extension DataImport: DataImporter {
    
    static func dataImport() {
    }
}
