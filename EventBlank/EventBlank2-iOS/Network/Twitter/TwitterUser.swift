//
//  TwitterUser.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 3/13/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON
import Kingfisher

class TwitterUser: Object {
    
    dynamic var id: Int32 = 0
    dynamic var name = ""
    dynamic var username = ""
    
    dynamic var _avatarUrl: String?
    
    var avatarUrl: NSURL? {
        set {
            _avatarUrl = newValue?.absoluteString
        }
        get {
            guard let avatarUrl = _avatarUrl else {
                return nil
            }
            return NSURL(string: avatarUrl)
        }
    }

    static override func primaryKey() -> String {
        return "id"
    }
    
    static override func ignoredProperties() -> [String] {
        return ["avatarUrl"]
    }
    
    required init() {
        super.init()
    }
    
    convenience init?(jsonObject obj: JSON) {
        self.init()
        
        //required properties
        guard let name = obj["name"].string,
            let id = obj["id"].int32,
            let username = obj["screen_name"].string,
            let avatarUrlString = obj["profile_image_url_https"].string,
            let avatarUrl = NSURL(string: avatarUrlString)
            else {
                return nil
        }
        
        self.name = name
        self.id = id
        self.username = username
        self.avatarUrl = avatarUrl
        
        ImagePrefetcher(urls: [avatarUrl]).start()
    }

}