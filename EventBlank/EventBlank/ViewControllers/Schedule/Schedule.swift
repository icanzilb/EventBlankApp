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

struct RightNowItems {
    let currentSessions: [Row]?
    let nextSessions: [Row]?
}

class Schedule {
    
    var database: Database {
        return DatabaseProvider.databases[eventDataFileName]!
    }

    var favorites: [Int]!
    var speakerFavorites: [Int]!

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
    
    func sessionsByStartTime(day: ScheduleDay, onlyFavorites: Bool = false) -> [ScheduleDaySection] {
        var result = [ScheduleDaySection]()
        
        let timeFormatter = NSDateFormatter()
        timeFormatter.timeStyle = .ShortStyle
        
        var lastBeginTime: Int = 0
        var rows = [Row]()

        //load sessions
        var sessions = database[SessionConfig.tableName]
            .join(database[SpeakerConfig.tableName], on: {Session.fk_speaker == Speaker.idColumn}())
            .join(database[TrackConfig.tableName], on: {Session.fk_track == Track.idColumn}())
            .join(database[LocationConfig.tableName], on: {Session.fk_location == Location.idColumn}())
            .filter(Session.beginTime > Int(day.startTimeStamp) && Session.beginTime < Int(day.endTimeStamp))
            .order(Session.beginTime.asc)
            .map {$0}
        
        //filter sessions
        if onlyFavorites {
            sessions = sessions.filter({ session in
                return find(self.favorites, session[Session.idColumn]) != nil ||
                    (find(self.speakerFavorites, session[Speaker.idColumn]) != nil)
            })
        }
        
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
    
    func rightNowItems(var day: ScheduleDay? = nil) -> RightNowItems? {
        let database = DatabaseProvider.databases[eventDataFileName]!
        
        let todayMorning = NSDate().dateAtStartOfDay().timeIntervalSince1970
        let todayEvening = NSDate().dateAtEndOfDay().timeIntervalSince1970
        
        //load sessions
        var sessions = database[SessionConfig.tableName]
            .join(database[SpeakerConfig.tableName], on: {Session.fk_speaker == Speaker.idColumn}())
            .join(database[TrackConfig.tableName], on: {Session.fk_track == Track.idColumn}())
            .join(database[LocationConfig.tableName], on: {Session.fk_location == Location.idColumn}())
            .filter(Session.beginTime > Int(todayMorning) && Session.beginTime < Int(todayEvening))
            .order(Session.beginTime.asc)
            .map {$0}
        
        //build schedule sections
        if day == nil {
            day = ScheduleDay(startTimeStamp: todayMorning, endTimeStamp: todayEvening, text: "dummy")
        }
        
        let items = Schedule().sessionsByStartTime(day!)
        let now = NSDate().timeIntervalSince1970
        
        var currentSectionIndex: Int? = nil
        
        for section in 0 ..< items.count {
            //this section
            let nowSection = items[section]
            var nowSectionTitle = nowSection.keys.first!
            let nowSession = nowSection.values.first!.first!
            let nowSessionStartTime = nowSession[Session.beginTime]
            
            if currentSectionIndex == section - 1 {
                //next upcoming session
                return RightNowItems(
                    currentSessions: items[currentSectionIndex!].values.first!,
                    nextSessions: items[section].values.first!)
            }
            
            //next section
            if items.count > section+1 {
                
                let nextSection = items[section+1]
                let nextSession = nextSection.values.first!.first!
                let nextSessionStartTime = nextSession[Session.beginTime]
                
                let rightNow = NSDate().timeIntervalSince1970
                
                if Double(nowSessionStartTime) < rightNow && rightNow < Double(nextSessionStartTime) {
                    //current session
                    currentSectionIndex = section
                }
            } else {
                //reset the current section index
                currentSectionIndex = nil
            }

        }
        
        if let currentSectionIndex = currentSectionIndex {
            return RightNowItems(currentSessions: items[currentSectionIndex].values.first!, nextSessions: nil)
        } else {
            return nil
        }
    }

}
