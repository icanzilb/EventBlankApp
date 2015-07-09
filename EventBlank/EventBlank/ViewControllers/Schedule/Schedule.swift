//
//  ScheduleController.swift
//  EventBlank
//
//  Created by Marin Todorov on 6/21/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import SQLite

struct ScheduleDay {
    let startTimeStamp: NSTimeInterval
    let endTimeStamp: NSTimeInterval
    let text: String
}

//TODO: update all entities with Swift 2.0 - add database provider via a protocol extension

typealias ScheduleDaySection = [String: [Row]]

class Schedule {
    
    func dayRanges() -> [ScheduleDay] {
        
        //read the event data
        let database = DatabaseProvider.databases[eventDataFileName]!
        let event = database[EventConfig.tableName].first!
        
        let beginDate = NSDate(timeIntervalSince1970: Double(event[Event.start]))
        let endDate = NSDate(timeIntervalSince1970: Double(event[Event.end]))
        
        //how many days?
        let nrOfDays = endDate.daysAfterDate(beginDate)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EE, MMM dd"
        
        var result = [ScheduleDay]()
        
        for var i = 0; i <= nrOfDays; i++ {
            let dayDate = beginDate.dateByAddingDays(i)
            result.append(ScheduleDay(
                startTimeStamp: dayDate.dateAtStartOfDay().timeIntervalSince1970,
                endTimeStamp: dayDate.dateAtEndOfDay().timeIntervalSince1970,
                text: dateFormatter.stringFromDate(dayDate)))
        }
        
        return result
    }
    
    func groupSessionsByStartTime(sessions: [Row]) -> [ScheduleDaySection] {
        var result = [ScheduleDaySection]()
        
        let timeFormatter = NSDateFormatter()
        timeFormatter.timeStyle = .ShortStyle
        
        var lastBeginTime: Int = 0
        var rows = [Row]()
        
        for session in sessions {
            if lastBeginTime>0 && session[Session.beginTime] > lastBeginTime {
                //push new section
                let newSectionTitle = timeFormatter.stringFromDate(NSDate(timeIntervalSince1970: Double(lastBeginTime)))
                let newSection: ScheduleDaySection = [newSectionTitle: rows]
                result.append(newSection)
                rows = []
            }
            rows.append(session)
            lastBeginTime = session[Session.beginTime]
        }
        
        if rows.count > 0 {
            let newSectionTitle = timeFormatter.stringFromDate(NSDate(timeIntervalSince1970: Double(lastBeginTime)))
            let newSection: ScheduleDaySection = [newSectionTitle: rows]
            result.append(newSection)
        }
        
        return result
    }
}
