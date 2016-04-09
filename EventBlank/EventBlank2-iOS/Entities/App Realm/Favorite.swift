//
//  Favorite.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 2/23/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import Foundation
import RealmSwift

class FavoriteSpeaker: Object {
    dynamic var speakerUuid: String = ""
    
    override class func primaryKey() -> String {
        return "speakerUuid"
    }
}

class FavoriteSession: Object {
    dynamic var sessionUuid: String = ""
    
    override class func primaryKey() -> String {
        return "sessionUuid"
    }
}