//
//  TrackConfig.swift
//  EventBlankProducer
//
//  Created by Marin Todorov on 3/14/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import Foundation
import RealmSwift

var SessionConfig = EntityConfig(
    tableName: "sessions",
    entityName: "Session",
    idColumnName: "id_session",
    titleColumnName: "title",
    listImageName: "EventBlankProducer.SessionsSplitViewController"
)

struct Session {
    //
    // columns
    //
    
    static let idColumn = Expression<Int>(SessionConfig.idColumnName)
    static let title = Expression<String>("title")
    static let description = Expression<String?>("description")
    static let beginTime = Expression<Int>("begin_time")
    static let fk_track = Expression<Int?>("fk_track")
    static let fk_speaker = Expression<Int?>("fk_speaker")
    static let fk_location = Expression<Int?>("fk_location")
    
    //
    // database
    //
    
    static func allSessions(startTimeStamp: NSTimeInterval? = nil, endTimeStamp: NSTimeInterval? = nil) -> [Row] {
        let database = DatabaseProvider.databases[eventDataFileName]!
        let sessionsTable = database[SessionConfig.tableName]
        return sessionsTable.order(Session.beginTime.desc).map {$0}
    }
    
}