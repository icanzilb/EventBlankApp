//
//  NewsController.swift
//  Twitter_test
//
//  Created by Marin Todorov on 6/18/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import SQLite

class NewsController {

    var database: Database {
        return DatabaseProvider.databases[eventDataFileName]!
    }
    
    func persistNews(tweets: [TweetModel]) -> [Row] {
        let newsTable = database[NewsConfig.tableName]

        return tweets.map {
            
            if let news = newsTable.filter(News.idColumn == $0.id).first {
                return news
            } else {
                //new row
                let values: [Setter] = [
                    News.idColumn <- $0.id,
                    News.created <- Int($0.created.timeIntervalSince1970),
                    News.news <- $0.text,
                    News.url <- $0.url?.absoluteString,
                    News.imageUrl <- $0.imageUrl?.absoluteString,
                    News.idUser <- $0.userId
                ]
                
                let newId = newsTable.insert(values).rowid
                return newsTable.filter(News.idColumn == $0.id).first!
            }
        
        }
        
    }
    
    func allNews(limit: Int = 20) -> [Row] {
        
        return database[NewsConfig.tableName]
            .order(News.created.desc, News.idColumn.desc)
            .limit(limit)
            .map {$0}
    }
    
    func persistImage(image: UIImage, forTweetId: Int64) {

        let newsTable = database[NewsConfig.tableName]
        let result = newsTable.filter(News.idColumn == forTweetId).update( News.image <- image.blobValue).changes
        
    }
}
