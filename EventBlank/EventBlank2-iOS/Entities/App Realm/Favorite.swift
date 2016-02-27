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
}

class FavoriteSession: Object {
    dynamic var name: String = ""
}