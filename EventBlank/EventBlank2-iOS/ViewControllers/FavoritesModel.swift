//
//  FavoritesModel.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 4/9/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa

class FavoritesModel {
    let sessionFavorites = Variable<[String]>([])
    let speakerFavorites = Variable<[String]>([])

    private let bag = DisposeBag()
    
    init() {
        //observe session favorites
        RealmProvider.appRealm.objects(Favorites).asObservableArray().map {results -> [String] in
            return results.first!.sessionIds
        }
        .bindTo(sessionFavorites)
        .addDisposableTo(bag)
        
        //observe speaker favorites
        RealmProvider.appRealm.objects(Favorites).asObservableArray().map {results -> [String] in
            return results.first!.speakerIds
        }
        .bindTo(speakerFavorites)
        .addDisposableTo(bag)
    }
    
    func updateSessionFavoriteTo(session: Session, to: Bool) {
        //remove favorite
        if sessionFavorites.value.contains(session.uuid) && to == false {
            try! RealmProvider.appRealm.write {
                if let oid = RealmProvider.appRealm.objects(ObjectId).filter("id = %@", session.uuid).first {
                    RealmProvider.appRealm.delete(oid)
                }
            }
            return
        }
        
        //add favorite
        if !sessionFavorites.value.contains(session.uuid) && to == true {
            try! RealmProvider.appRealm.write {
                let oid = RealmProvider.appRealm.objects(ObjectId).filter("id = %@", session.uuid).first ?? ObjectId(id: session.uuid)
                RealmProvider.appRealm.objects(Favorites).first!.sessions.append(oid)
            }
        }
    }

    func updateSpeakerFavoriteTo(speaker: Speaker, to: Bool) {
        //remove favorite
        if speakerFavorites.value.contains(speaker.uuid) && to == false {
            try! RealmProvider.appRealm.write {
                if let favorites = RealmProvider.appRealm.objects(Favorites).first,
                    let oid = favorites.speakers.filter("id = %@", speaker.uuid).first,
                    let index = favorites.speakers.indexOf(oid) {
                    
                    favorites.speakers.removeAtIndex(index)
                    RealmProvider.appRealm.delete(oid)
                }
            }
            return
        }
        
        //add favorite
        if !speakerFavorites.value.contains(speaker.uuid) && to == true {
            try! RealmProvider.appRealm.write {
                let oid = ObjectId(id: speaker.uuid)
                RealmProvider.appRealm.objects(Favorites).first!.speakers.append(oid)
            }
        }
    }

}