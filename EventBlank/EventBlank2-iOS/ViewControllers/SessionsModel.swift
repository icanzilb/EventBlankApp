//
//  SessionsModel.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 4/9/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

class SessionsModel {
    let bag = DisposeBag()
    
    //favorites
    let speakerFavorites = Variable<[String]>([])
    let sessionFavorites = Variable<[String]>([])

    init() {
        //observe speaker favorites
        RealmProvider.appRealm.objects(Favorites).asObservableArray().map {results -> [String] in
            return results.first!.speakerIds
        }
        .bindTo(speakerFavorites)
        .addDisposableTo(bag)
        
        //observe session favorites
        RealmProvider.appRealm.objects(Favorites).asObservableArray().map {results -> [String] in
            return results.first!.sessionIds
        }
        .bindTo(sessionFavorites)
        .addDisposableTo(bag)
    }
    
    func sessions(day: Schedule.Day, onlyFavorites: Bool) -> Results<Session> {
        return RealmProvider.eventRealm.objects(Session).filter("beginTime >= %@ AND beginTime <= %@", day.startTime, day.endTime).sorted("beginTime")
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

}