//
//  TrackConfig.swift
//  EventBlankProducer
//
//  Created by Marin Todorov on 3/14/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import Foundation
import SQLite

var LocationConfig = EntityConfig(
    tableName: "locations",
    entityName: "Location",
    idColumnName: "id_location",
    titleColumnName: "location",
    listImageName: "EventBlankProducer.LocationsSplitViewController"
)

struct Location {
    
    //
    // columns
    //
    
    static let idColumn = Expression<Int>(LocationConfig.idColumnName)
    static let name = Expression<String>(LocationConfig.titleColumnName)
    static let description = Expression<String?>("location_description")
    static let map = Expression<Blob?>("location_map")
}