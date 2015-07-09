//
//  TweetModel.swift
//  Twitter_test
//
//  Created by Marin Todorov on 6/18/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit

struct TweetModel {
    
    let created: NSDate
    let url: NSURL?
    let imageUrl: NSURL?
    let id: Int64
    let text: String
    let userId: Int64
    
    static let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        return formatter
        }()
    
    static func createFromTweetObject(obj: NSDictionary) -> TweetModel {
        let entities = obj["entities"] as! NSDictionary

        let created = dateFormatter.dateFromString(obj["created_at"]! as! String)!

        var url: NSURL? = nil
        if let urls = entities["urls"] as? NSArray, let urlDict = urls.firstObject as? NSDictionary, let urlValue = urlDict["expanded_url"] as? String {
            url = NSURL(string: urlValue)
        }
        
        var imageUrl: NSURL? = nil
        if let media = entities["media"] as? NSArray,
            let photoDict = media.filteredArrayUsingPredicate(NSPredicate(format: "type == 'photo'", argumentArray: [])).first as? NSDictionary,
            let urlValue = photoDict["media_url"] as? String {
            
                imageUrl = NSURL(string: urlValue)
        }
        
        let id = Int64((obj["id"] as! NSNumber).integerValue)
        let text = obj["text"] as! String
        
        let userId = Int64(((obj["user"] as! NSDictionary)["id"] as! NSNumber).integerValue)
        
        return TweetModel(created: created, url: url, imageUrl: imageUrl, id: id, text: text, userId: userId)
    }
}