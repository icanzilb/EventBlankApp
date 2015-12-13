//
//  TrackConfig.swift
//  EventBlankProducer
//
//  Created by Marin Todorov on 3/14/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import Foundation
import RealmSwift

var TrackConfig = EntityConfig(
    tableName: "tracks",
    entityName: "Track",
    idColumnName: "id_track",
    titleColumnName: "track",
    listImageName: "EventBlankProducer.TracksSplitViewController"
)

struct Track {
    static let idColumn = Expression<Int>(TrackConfig.idColumnName)
    static let track = Expression<String?>("track")
    static let description = Expression<String?>("track_description")
}