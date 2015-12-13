//
//  RightNowModel.swift
//  EventBlank
//
//  Created by Marin Todorov on 9/21/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import RealmSwift

class RightNowModel {

  let dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    formatter.timeStyle = .ShortStyle
    formatter.dateFormat = .None
    return formatter
    }()
  

  func current(event: Row) -> (String, Bool) {
    
    let now = Int(NSDate().timeIntervalSince1970)
    
    if now < event[Event.start] {
      //before the event
      
      let remaining = event[Event.start] - now
      let days = Int(ceil(Double(remaining) / Double(24 * 60 * 60)))
      
      if days > 1 {
        return ("The event starts in \(days) days!", false)
      } else {
        return ("Starting within hours, get ready!", false)
      }
      
    } else if now > event[Event.start] && now < event[Event.end] {
      //during the event
      
      if let nowItems = Schedule().rightNowItems() {
        var result = ""
        
        if let currentSessions = nowItems.currentSessions {
          result = "Currently: \(currentSessions.first![Session.title]) by \(currentSessions.first![Speaker.name])"
        }
        
        if let nextSessions = nowItems.nextSessions {
          let sessionDate = NSDate(timeIntervalSince1970: Double(nextSessions.first![Session.beginTime]))
          result += "\nNext at \(dateFormatter.stringFromDate(sessionDate)): \(nextSessions.first![Session.title]) by \(nextSessions.first![Speaker.name])"
        }
        
        return (result, true)
      }
      
      return ("The event is ongoing", false)
      
      
    } else {
      //after the event
      return ("The event has already finished. You can still browse the speaker and sessions data in the app.", false)
    }
  }
  
}
