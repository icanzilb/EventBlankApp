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
    //favorites
    let speakerFavorites = RealmProvider.appRealm.objects(FavoriteSpeaker).asObservableArray()
        .map { $0.map {speaker in speaker.speakerUuid} }
    let sessionFavorites = RealmProvider.appRealm.objects(FavoriteSession).asObservableArray()
        .map { $0.map {session in session.sessionUuid} }

    func sessions(day: Schedule.Day, onlyFavorites: Bool) -> Results<Session> {
        return RealmProvider.eventRealm.objects(Session).filter("beginTime >= %@ AND beginTime <= %@", day.startTime, day.endTime).sorted("beginTime")
    }
    
}