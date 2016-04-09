//
//  SessionDetailsModel.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 4/9/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa

class SessionDetailsModel {
    private var id: String!
    
    init(id: String) {
        self.id = id
    }
    
    var sessionDetails: Results<Session> {
        return RealmProvider.eventRealm.objects(Session).filter("uuid = %@", id)
    }
}