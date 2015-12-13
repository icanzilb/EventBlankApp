//
//  ChatController.swift
//  Twitter_test
//
//  Created by Marin Todorov on 6/18/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import RealmSwift

class ChatController {
    
    var database: Database {
        return DatabaseProvider.databases[appDataFileName]!
    }

    func persistMessages(tweets: [TweetModel]) -> [Row] {
        let chatTable = database[ChatConfig.tableName]
        
        return tweets.map {
            
            if let message = chatTable.filter(Chat.idColumn == $0.id).first {
                return message
            } else {
                //new row
                let values: [Setter] = [
                    Chat.idColumn <- $0.id,
                    Chat.created <- Int($0.created.timeIntervalSince1970),
                    Chat.idUser <- $0.userId,
                    Chat.message <- $0.text,
                    Chat.url <- $0.url?.absoluteString,
                    Chat.imageUrl <- $0.imageUrl?.absoluteString
                ]
                
                chatTable.insert(values).rowid!
                return chatTable.filter(Chat.idColumn == $0.id).first!
            }
        }
    }
    
    func allMessages(limit: Int = 50) -> [Row] {
        return database[ChatConfig.tableName]
            .order(Chat.created.desc, Chat.idColumn.desc)
            .limit(limit)
            .map {$0}
    }
    
    func persistImage(image: UIImage, forTweetId: Int64) {
        let chatTable = database[ChatConfig.tableName]
        let result = chatTable.filter(Chat.idColumn == forTweetId).update( Chat.image <- image.blobValue).changes
    }
}
