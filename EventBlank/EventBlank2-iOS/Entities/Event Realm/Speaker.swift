//
//  SpeakerConfig.swift
//  EventBlankProducer
//
//  Created by Marin Todorov on 3/14/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import Foundation
import RealmSwift

class Speaker: Object {
    dynamic var uuid = NSUUID().UUIDString
    
    dynamic var name = ""
    dynamic var bio: String?
    dynamic var url: String?
    dynamic var twitter: String?
    
    dynamic var _photo: NSData?
    var photo: UIImage? {
        set {
            _photo = newValue?.dataValue
        }
        get {
            return _photo?.imageValue
        }
    }
    
    let favorite = RealmOptional<Bool>()
    
    override class func primaryKey() -> String {
        return "uuid"
    }

    override class func ignoredProperties() -> [String] {
        return ["photo"]
    }
}