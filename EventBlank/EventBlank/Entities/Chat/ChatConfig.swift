//
//  ChatConfig.swift
//  Twitter_test
//
//  Created by Marin Todorov on 6/18/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import Foundation
import SQLite

var ChatConfig = EntityConfig(
    tableName: "chat",
    entityName: "Chat",
    idColumnName: "id_chat",
    titleColumnName: "",
    listImageName: ""
)

struct Chat {
    
    //
    // Columns
    //
    
    static let idColumn = Expression<Int64>(ChatConfig.idColumnName)
    static let message = Expression<String>("message")
    static let created = Expression<Int>("created")
    static let url = Expression<String?>("url")
    static let image = Expression<Blob?>("image")
    static let imageUrl = Expression<String?>("image_url")
    static let idUser = Expression<Int64>("id_user")
    static let isNew = Expression<Bool>("is_new")
}