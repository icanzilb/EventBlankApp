//
//  EventModel.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 4/9/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import Foundation
import RealmSwift

class EventModel {
    
    func eventData() -> EventData {
        return RealmProvider.eventRealm.objects(EventData).first!
    }
    
}
