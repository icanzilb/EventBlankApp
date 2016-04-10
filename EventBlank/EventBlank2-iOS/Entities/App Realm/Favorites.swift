//
//  Favorite.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 2/23/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import Foundation
import RealmSwift

class Favorites: Object {
    let speakers = List<ObjectId>()
    let sessions = List<ObjectId>()
    
    var speakerIds: [String] {
        return speakers.map {$0.id}
    }
    var sessionIds: [String] {
        return sessions.map {$0.id}
    }
}

class ObjectId: Object {
    dynamic var id = ""
    
    convenience init(id: String) {
        self.init()
        self.id = id
    }
}