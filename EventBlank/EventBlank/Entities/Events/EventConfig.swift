//
//  EventConfig.swift
//  EventBlankProducer
//
//  Created by Marin Todorov on 3/25/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import Foundation
import SQLite

var EventConfig = EntityConfig(
    tableName: "events",
    entityName: "Event",
    idColumnName: "id_event",
    titleColumnName: "title",
    listImageName: "EventBlankProducer.EventDataSplitViewController"
)

private var sharedEvent: Row! = nil

struct Event {
    
    //
    // Columns
    //
    
    static let idColumn = Expression<Int>("id_event")
    static let name = Expression<String>("title")
    static let subtitle = Expression<String?>("subtitle")
    
    static let start = Expression<Int>("begin_date")
    static let end = Expression<Int>("end_date")
    
    static let organizer = Expression<String>("organizer")
    
    static let logo = Expression<Blob?>("logo")
    
    static let twitterAdmin = Expression<String?>("twitter_admin")
    static let twitterTag = Expression<String?>("twitter_tag")
    static let twitterChatter = Expression<Int>("twitter_chatter")
    
    static let mainColor = Expression<String>("main_color")
    static let secondaryColor = Expression<String>("secondary_color")
    static let ternaryColor = Expression<String>("ternary_color")
    
    static let updateFileUrl = Expression<String?>("update_file_url")
    
    //
    // shared event
    //
    static var event: Row {
        if sharedEvent != nil {
            return sharedEvent!
        }
        
        let eventsTable = DatabaseProvider.databases[eventDataFileName]![EventConfig.tableName]
        sharedEvent = eventsTable.first!
        return sharedEvent
    }
}