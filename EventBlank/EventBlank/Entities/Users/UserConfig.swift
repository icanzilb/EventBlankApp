//
//  UserConfig.swift
//  Twitter_test
//
//  Created by Marin Todorov on 6/18/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import Foundation
import RealmSwift

var UserConfig = EntityConfig(
    tableName: "users",
    entityName: "User",
    idColumnName: "id_user",
    titleColumnName: "",
    listImageName: ""
)

struct User {
    
    //
    // columns
    //
    
    static let idColumn = Expression<Int64>(UserConfig.idColumnName)
    static let photo = Expression<Blob?>("image")
    static let photoUrl = Expression<String?>("image_url")
    static let name = Expression<String>("name")
    static let username = Expression<String>("username")
}