//
//  SessionsModel.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 4/9/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import Foundation
import RealmSwift

class SessionsModel {
    func sessions(day: Schedule.Day, onlyFavorites: Bool) -> Results<Session> {
        return RealmProvider.eventRealm.objects(Session).filter("beginTime >= %@ AND beginTime <= %@", day.startTime, day.endTime).sorted("beginTime")
    }
}