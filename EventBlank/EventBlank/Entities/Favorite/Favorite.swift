//
//  Favorite.swift
//  EventBlank
//
//  Created by Marin Todorov on 6/21/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import Foundation
import RealmSwift

var FavoriteConfig = EntityConfig(
    tableName: "favorites",
    entityName: "Favorite",
    idColumnName: "id_favorite",
    titleColumnName: "",
    listImageName: ""
)

struct Favorite {
    
    //
    // columns
    //
    
    static let idColumn = Expression<Int>(FavoriteConfig.idColumnName)
    static let idSession = Expression<Int>("id_session")
    static let idSpeaker = Expression<Int>("id_speaker")
    
    //
    // sessions
    //
    
    static func allSessionFavoritesIDs() -> [Int] {
        let database = DatabaseProvider.databases[appDataFileName]!
//        return database.prepare(FavoriteConfig.tableName)
//            .filter(Favorite.idSession > 0)
//            .map {$0[Favorite.idSession]}
        return []
    }
    
    static func saveSessionId(id: Int) {
        let database = DatabaseProvider.databases[appDataFileName]!
        let favorites = Table(FavoriteConfig.tableName)
        
        try! database.run(favorites.insert(Favorite.idSession <- id))
    }
    
    static func removeSessionId(id: Int) {
        let database = DatabaseProvider.databases[appDataFileName]!
        let favorites = Table(FavoriteConfig.tableName)
        
        try! database.run(favorites.filter({Favorite.idSession == id}()).delete())
    }
    
    //
    // speakers
    //
    
    static func allSpeakerFavoriteIDs() -> [Int] {
        let database = DatabaseProvider.databases[appDataFileName]!
        let favorites = Table(FavoriteConfig.tableName)
        
//        return database.prepare(FavoriteConfig.tableName)
//            .filter(Favorite.idSpeaker > 0)
//            .map {$0[Favorite.idSpeaker]}
        return []
    }
    
    static func saveSpeakerId(id: Int) {
        let database = DatabaseProvider.databases[appDataFileName]!
        let favorites = Table(FavoriteConfig.tableName)
        
        try! database.run(favorites.insert(Favorite.idSpeaker <- id))
    }
    
    static func removeSpeakerId(id: Int) {
        let database = DatabaseProvider.databases[appDataFileName]!
        let favorites = Table(FavoriteConfig.tableName)
        
        try! database.run(favorites.filter({Favorite.idSpeaker == id}()).delete())
    }
    
}
