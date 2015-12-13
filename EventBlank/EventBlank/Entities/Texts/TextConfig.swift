//
//  TracksConfig.swift
//  EventBlankProducer
//
//  Created by Marin Todorov on 4/4/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import Foundation
import RealmSwift

var TextConfig = EntityConfig(
    tableName: "texts",
    entityName: "Text",
    idColumnName: "id_text",
    titleColumnName: "title",
    listImageName: "EventBlankProducer.TextsSplitViewController"
)

struct Text {
    static let idColumn = Expression<Int>(TextConfig.idColumnName)
    static let title = Expression<String>(TextConfig.titleColumnName)
    static let content = Expression<String?>("content")
}