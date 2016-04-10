//
//  Photo.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 4/10/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import Foundation
import RealmSwift

class Photo: Object {

    convenience init(_ image: NSData?) {
        self.init()
        self.data = image
    }
    
    dynamic var url: String?
    dynamic var data: NSData?
    
    override class func indexedProperties() -> [String] {
        return ["url"]
    }
}