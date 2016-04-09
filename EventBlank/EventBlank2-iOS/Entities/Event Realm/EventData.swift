//
//  EventData.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 2/19/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import UIKit
import RealmSwift

class EventData: Object {

    dynamic var title = ""
    dynamic var subtitle = ""
    dynamic var organizer = ""
    dynamic private var _logo: NSData?
    var logo: UIImage? {
        get {
            return _logo?.imageValue
        }
        set {
            _logo = newValue?.dataValue
        }
    }
    
    dynamic var twitterTag: String?
    dynamic var twitterAdmin: String?
    
    dynamic private var _mainColor = ""
    var mainColor: UIColor {
        get {
            return UIColor(hexString: _mainColor)
        }
        set {
            _mainColor = newValue.toHexString()
        }
    }
    
    dynamic var secondaryColor: String?
    dynamic var ternaryColor: String?
    
    dynamic var twitterChatter = false
    
    dynamic var updateFileUrl: String?
    
    //methods
    
    static var defaultEvent: EventData {
        return RealmProvider.eventRealm.objects(EventData).first!
    }
    
    override class func ignoredProperties() -> [String] {
        return ["mainColor", "logo"]
    }
}
