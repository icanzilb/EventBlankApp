//
//  NewsConfig.swift
//  Twitter_test
//
//  Created by Marin Todorov on 6/18/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import Foundation
import RealmSwift

var NewsConfig = EntityConfig(
    tableName: "news",
    entityName: "News",
    idColumnName: "id_news",
    titleColumnName: "",
    listImageName: ""
)

struct News {
    static let idColumn = Expression<Int64>(NewsConfig.idColumnName)
    static let news = Expression<String?>("news")
    static let created = Expression<Int>("created")
    static let url = Expression<String?>("url")
    static let image = Expression<Blob?>("image")
    static let imageUrl = Expression<String?>("image_url")
    static let isNew = Expression<Bool>("is_new")
    static let idUser = Expression<Int64>("id_user")
}