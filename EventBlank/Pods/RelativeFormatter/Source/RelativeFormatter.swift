//
//  RelativeFormatter.swift
//  RelativeFormatter
//
//  Created by David Collado Sela on 12/5/15.
//  Copyright (c) 2015 David Collado Sela. All rights reserved.
//

import Foundation

public enum Precision{
    case Year,Month,Week,Day,Hour,Minute,Second
}

extension NSDate{
    
    public func relativeFormatted(idiomatic:Bool=false,precision:Precision=Precision.Second)->String{
        let calendar = NSCalendar.currentCalendar()
        let unitFlags: NSCalendarUnit = [NSCalendarUnit.Minute, NSCalendarUnit.Hour, NSCalendarUnit.Day, NSCalendarUnit.WeekOfYear, NSCalendarUnit.Month, NSCalendarUnit.Year, NSCalendarUnit.Second]
        let now = NSDate().normalized(precision)
        let normalized = self.normalized(precision)
        let formattedDateData:(key:String,count:Int?)
        if(normalized.timeIntervalSince1970 < now.timeIntervalSince1970){
            let components:NSDateComponents = calendar.components(unitFlags, fromDate: normalized, toDate: now, options: [])
            formattedDateData = RelativeFormatter.getPastKeyAndCount(components,idiomatic:idiomatic,precision:precision)
        }else{
            let components:NSDateComponents = calendar.components(unitFlags, fromDate: now, toDate: normalized, options: [])
            formattedDateData = RelativeFormatter.getFutureKeyAndCount(components,idiomatic:idiomatic,precision:precision)
        }
        return LocalizationHelper.localize(formattedDateData.key,count:formattedDateData.count)
    }
    
    func normalized(precision:Precision)->NSDate{
        let unitFlags: NSCalendarUnit = [NSCalendarUnit.Minute, NSCalendarUnit.Hour, NSCalendarUnit.Day, NSCalendarUnit.WeekOfYear, NSCalendarUnit.Month, NSCalendarUnit.Year, NSCalendarUnit.Second]
        let nowDateNewcomponents = NSDateComponents()
        let nowComponets = NSCalendar.currentCalendar().components(unitFlags, fromDate: self)
        switch precision{
        case .Year:
            nowDateNewcomponents.year = nowComponets.year
        case .Month:
            nowDateNewcomponents.year = nowComponets.year
            nowDateNewcomponents.month = nowComponets.month
        case .Week:
            nowDateNewcomponents.year = nowComponets.year
            nowDateNewcomponents.month = nowComponets.month
            nowDateNewcomponents.weekOfYear = nowComponets.weekOfYear
        case .Day:
            nowDateNewcomponents.year = nowComponets.year
            nowDateNewcomponents.month = nowComponets.month
            nowDateNewcomponents.weekOfYear = nowComponets.weekOfYear
            nowDateNewcomponents.day = nowComponets.day
        case .Hour:
            nowDateNewcomponents.year = nowComponets.year
            nowDateNewcomponents.month = nowComponets.month
            nowDateNewcomponents.weekOfYear = nowComponets.weekOfYear
            nowDateNewcomponents.day = nowComponets.day
            nowDateNewcomponents.hour = nowComponets.hour
        case .Minute:
            nowDateNewcomponents.year = nowComponets.year
            nowDateNewcomponents.month = nowComponets.month
            nowDateNewcomponents.weekOfYear = nowComponets.weekOfYear
            nowDateNewcomponents.day = nowComponets.day
            nowDateNewcomponents.hour = nowComponets.hour
            nowDateNewcomponents.minute = nowComponets.minute
        case .Second:
            nowDateNewcomponents.year = nowComponets.year
            nowDateNewcomponents.month = nowComponets.month
            nowDateNewcomponents.weekOfYear = nowComponets.weekOfYear
            nowDateNewcomponents.day = nowComponets.day
            nowDateNewcomponents.hour = nowComponets.hour
            nowDateNewcomponents.minute = nowComponets.minute
            nowDateNewcomponents.second = nowComponets.second
        }
        return NSCalendar.currentCalendar().dateFromComponents(nowDateNewcomponents)!
    }
}

class RelativeFormatter {
    
    class func getPastKeyAndCount(components:NSDateComponents,idiomatic:Bool,precision:Precision)->(key:String,count:Int?){
        var key = ""
        var count:Int?
        if(components.year >= 2){
            count = components.year
            key = "yearsago"
        }
        else if(components.year >= 1){
            key = "yearago"
        }
        else if(components.year == 0 && precision == Precision.Year){
            return ("thisyear",nil)
        }
        else if(components.month >= 2){
            count = components.month
            key = "monthsago"
        }
        else if(components.month >= 1){
            key = "monthago"
            
        }
        else if(components.month == 0 && precision == Precision.Month){
            return ("thismonth",nil)
        }
        else if(components.weekOfYear >= 2){
            count = components.weekOfYear
            key = "weeksago"
        }
        else if(components.weekOfYear >= 1){
            key = "weekago"
        }
        else if(components.weekOfYear == 0 && precision == Precision.Week){
            return ("thisweek",nil)
        }
        else if(components.day >= 2){
            count = components.day
            key = "daysago"
        }
        else if(components.day >= 1){
            key = "dayago"
            if(idiomatic){
                key = key + "-idiomatic"
            }
        }
        else if(components.day == 0 && precision == Precision.Day){
            return ("today",nil)
        }
        else if(components.hour >= 2){
            count = components.hour
            key = "hoursago"
        }
        else if(components.hour >= 1){
            key = "hourago"
        }
        else if(components.hour == 0 && precision == Precision.Hour){
            return ("thishour",nil)
        }
        else if(components.minute >= 2){
            count = components.minute
            key = "minutesago"
        }
        else if(components.minute >= 1){
            key = "minuteago"
        }
        else if(components.minute == 0 && precision == Precision.Minute){
            return ("thisminute",nil)
        }
        else if(components.second >= 2){
            count = components.second
            key = "secondsago"
            if(idiomatic){
                key = key + "-idiomatic"
            }
        }
        else{
            key = "secondago"
            if(idiomatic){
                key = "now"
            }
        }
        
        return (key,count)
    }
    
    class func getFutureKeyAndCount(components:NSDateComponents,idiomatic:Bool,precision:Precision)->(key:String,count:Int?){
        var key = ""
        var count:Int?
        if(components.year >= 2){
            count = components.year
            key = "yearsahead"
        }
        else if(components.year >= 1){
            key = "yearahead"
        }
        else if(components.year == 0 && precision == Precision.Year){
            return ("thisyear",nil)
        }
        else if(components.month >= 2){
            count = components.month
            key = "monthsahead"
        }
        else if(components.month >= 1){
            key = "monthahead"
        }
        else if(components.month == 0 && precision == Precision.Month){
            return ("thismonth",nil)
        }
        else if(components.weekOfYear >= 2){
            count = components.weekOfYear
            key = "weeksahead"
        }
        else if(components.weekOfYear >= 1){
            key = "weekahead"
        }
        else if(components.weekOfYear == 0 && precision == Precision.Week){
            return ("thisweek",nil)
        }
        else if(components.day >= 2){
            count = components.day
            key = "daysahead"
        }
        else if(components.day >= 1){
            key = "dayahead"
            if(idiomatic){
                key = key + "-idiomatic"
            }
        }
        else if(components.day == 0 && precision == Precision.Day){
            return ("today",nil)
        }
        else if(components.hour >= 2){
            count = components.hour
            key = "hoursahead"
        }
        else if(components.hour >= 1){
            key = "hourahead"
        }
        else if(components.hour == 0 && precision == Precision.Hour){
            return ("thishour",nil)
        }
        else if(components.minute >= 2){
            count = components.minute
            key = "minutesahead"
        }
        else if(components.minute >= 1){
            key = "minuteahead"
        }
        else if(components.minute == 0 && precision == Precision.Minute){
            return ("thisminute",nil)
        }
        else if(components.second >= 2){
            count = components.second
            key = "secondsahead"
            if(idiomatic){
                key = key + "-idiomatic"
            }
        }
        else{
            key = "secondahead"
            if(idiomatic){
                key = "now"
            }
        }
        
        return (key,count)
    }
}
