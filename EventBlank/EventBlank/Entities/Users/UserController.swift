//
//  UserController.swift
//  Twitter_test
//
//  Created by Marin Todorov on 6/19/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import RealmSwift

class UserController: UIViewController {

    var database: Connection {
        return DatabaseProvider.databases[appDataFileName]!
    }

    func persistUsers(users: [UserModel]) -> [Row] {
        
        let usersTable = database[UserConfig.tableName]
        
        return users.map {
            
            if let user = usersTable.filter(User.idColumn == $0.idUser).first {
                return user
            } else {
                let values: [Setter] = [
                    User.idColumn <- $0.idUser,
                    User.name <- $0.name,
                    User.username <- $0.username,
                    User.photoUrl <- $0.imageUrl.absoluteString
                ]
                
                let newId = usersTable.insert(values).rowid
                return usersTable.filter(User.idColumn ==  newId!).first!
            }
        }
        
    }
    
    
    func lookupUserImage(row: Row, completion: (UIImage?)->Void) {
        //check for persisted twitter photo
        if row[Speaker.photo]?.imageValue == nil, var username = row[Speaker.twitter] {
            
            if username.hasPrefix("@") {
                username = username.stringByReplacingOccurrencesOfString("@", withString: "", options: nil, range: nil)
            }
            
            let usersTable = database[UserConfig.tableName]
            if let user = usersTable.filter(User.username == username).first {
                
                //cached twitter image
                if let image = user[User.photo]?.imageValue {
                    
                    //save image
                    persistSpeakerImage(image, speakerId: row[Speaker.idColumn])
                    
                    //update cell
                    completion(image)
                    
                } else if let imageUrlString = user[User.photoUrl], let imageUrl = NSURL(string: imageUrlString) {
                    
                    //fetch remote image
                    TwitterController().getImageWithUrl(imageUrl, completion: {image in
                        if let image = image {
                            //persist image
                            self.persistUserImage(image, userId: user[User.idColumn])
                            self.persistSpeakerImage(image, speakerId: row[Speaker.idColumn])
                            
                            //update cell
                            completion(image)
                        }
                    })
                    
                }
                
            } else {
                //fetch user from twitter and fetch image
                let twitter = TwitterController()
                twitter.authorize({success in
                    if success {
                        twitter.getUser(username, completion: {user in
                            if let user = user {
                                //save user
                                self.persistUsers([user])
                                
                                //fetch remote image
                                twitter.getImageWithUrl(user.imageUrl, completion: {image in
                                    if let image = image {
                                        //persist image
                                        self.persistUserImage(image, userId: user.idUser)
                                        self.persistSpeakerImage(image, speakerId: row[Speaker.idColumn])
                                        
                                        //update cell
                                        completion(image)
                                    }
                                })
                                
                            }
                        })
                    }
                })
            }
        }
    }
    
    func persistSpeakerImage(image: UIImage, speakerId: Int) {
        //save photo in speakers table
        let speakersTable = database[SpeakerConfig.tableName]
        speakersTable
            .filter(Speaker.idColumn == speakerId)
            .update(Speaker.photo <- image.blobValue)
    }
    
    func persistUserImage(image: UIImage, userId: Int64) {
        //save photo in users table
        let usersTable = database[UserConfig.tableName]
        usersTable
            .filter(User.idColumn == userId)
            .update(User.photo <- image.blobValue)
    }

}
