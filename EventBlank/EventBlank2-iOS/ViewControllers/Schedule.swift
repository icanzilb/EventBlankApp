//
//  Schedule.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 4/9/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import Foundation
import RealmSwift
import AFDateHelper

class Schedule {
    struct Day {
        let startTime: NSDate
        let endTime: NSDate
        let text: String
    }

    private lazy var dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EE, MMM dd"
        return dateFormatter
    }()
    
    func dayRanges() -> [Day] {
        let beginDate = (RealmProvider.eventRealm.objects(Session).min("beginTime")! as NSDate).dateAtStartOfDay()
        let endDate = (RealmProvider.eventRealm.objects(Session).max("beginTime")! as NSDate).dateAtEndOfDay()
        
        let nrOfDays = endDate.daysAfterDate(beginDate)
        
        return (0...nrOfDays).map {i in
            let dayDate = beginDate.dateByAddingDays(i)
            return Day(
                startTime: dayDate.dateAtStartOfDay(),
                endTime: dayDate.dateAtEndOfDay(),
                text: dateFormatter.stringFromDate(dayDate))
        }
    }
}