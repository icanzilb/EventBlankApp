//
//  FavoritesModel.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 4/9/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import Foundation
import RealmSwift

class FavoritesModel {
    
    
    
    func updateSessionFavoriteTo(sessionUuid: String, to: Bool) {

        
//        let fav = RealmProvider.appRealm.objectForPrimaryKey(FavoriteSession.self, key: sessionUuid)
//        
//        if let fav = fav where to == false {
//            try! RealmProvider.appRealm.write {
//                RealmProvider.appRealm.delete(fav)
//            }
//        }
//        if fav == nil && to == true {
//            try! RealmProvider.appRealm.write {
//                let newFav = FavoriteSession()
//                newFav.sessionUuid = sessionUuid
//                RealmProvider.appRealm.add(newFav)
//            }
//        }
    }
    
}