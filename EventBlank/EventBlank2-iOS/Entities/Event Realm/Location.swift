//
//  Location.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 2/20/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import Foundation
import RealmSwift

class Location: Object {
    
    dynamic var location = ""
    dynamic var locationDescription = ""
    dynamic var _map: NSData?
    var map: UIImage? {
        get {
            return _map?.imageValue
        }
        set {
            _map = newValue?.dataValue
        }
    }
    
    dynamic var lat: Double = 0.0
    dynamic var lng: Double = 0.0
    
}