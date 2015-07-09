//
//  UserModel.swift
//  Twitter_test
//
//  Created by Marin Todorov on 6/18/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import Foundation

struct UserModel {
    
    let idUser: Int64
    let name: String
    let username: String
    
    let imageUrl: NSURL
    
    static func createFromUserObject(obj: NSDictionary) -> UserModel {
        
        let idUser = Int64((obj["id"] as! NSNumber).integerValue)
        let username = obj["screen_name"] as! String
        let name = obj["name"] as! String
        let imageUrl = NSURL(string: obj["profile_image_url"] as! String)!
        
        return UserModel(idUser: idUser, name: name, username: username, imageUrl: imageUrl)
    }
}