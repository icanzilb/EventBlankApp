//
//  TwitterController.swift
//  Twitter_test
//
//  Created by Marin Todorov on 6/18/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import Social
import Accounts

class TwitterController: NSObject {

    var account: ACAccount?
    
    func authorize(completion: (Bool)->Void) {
        
        let accountStore = ACAccountStore()
        let accountType  = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        accountStore.requestAccessToAccountsWithType(accountType, options: nil, completion: {success, error in
            if let twitterAccount = accountStore.accountsWithAccountType(accountType).first as? ACAccount {
                self.account = twitterAccount
                completion(true)
            } else {
                //add throws in Swift 2.0
                completion(false)
            }
        })
    }
    
    func getTimeLineForUsername(username: String, completion: ([TweetModel], UserModel?)->Void) {
        
        let parameters: [String: String] = [
            "screen_name" : username.hasPrefix("@") ? username : "@"+username,
            "include_rts" : "0",
            "trim_user" : "0",
            "count" : "20"]
        
        let request = SLRequest(
            forServiceType: SLServiceTypeTwitter,
            requestMethod: SLRequestMethod.GET,
            URL: NSURL(string: "https://api.twitter.com/1.1/statuses/user_timeline.json")!,
            parameters: parameters
        )
        
        request.account = account
        request.performRequestWithHandler({responseData, urlResponse, error in
            if let error = error {
                println("error making request: \(error)")
                return
            }
            
            if let results = NSJSONSerialization.JSONObjectWithData(responseData, options: nil, error: nil) as? [NSDictionary] {
                var tweets = results.map {TweetModel.createFromTweetObject($0)}
                var user = results.map { UserModel.createFromUserObject( $0["user"] as! NSDictionary) }.first
                
                completion(tweets, user)
            } else {
                //add throw for Swift 2.0
                completion([], nil)
            }
        })
    }
    
    func getImageWithUrl(imageUrl: NSURL, completion: (UIImage?)->Void) {
        let task = NSURLSession.sharedSession().downloadTaskWithURL(imageUrl, completionHandler: {url, response, error in
            if error == nil, let data = NSData(contentsOfURL: url), let image = UIImage(data: data) {
                completion(image)
            } else {
                println("download error: \(error)")
                completion(nil)
            }
        })
        task.resume()
    }
    
    func getSearchForTerm(term: String, completion: ([TweetModel], [UserModel])->Void) {
        
        let parameters: [String: String] = [
            "q": term,
//            "result_type": "all",
            "trim_user": "0",
            "count": "20"]
        
        let request = SLRequest(
            forServiceType: SLServiceTypeTwitter,
            requestMethod: SLRequestMethod.GET,
            URL: NSURL(string: "https://api.twitter.com/1.1/search/tweets.json")!,
            parameters: parameters
        )
        
        request.account = account
        request.performRequestWithHandler({responseData, urlResponse, error in
            if let error = error {
                println("error making request: \(error)")
                return
            }
            
            if let result = NSJSONSerialization.JSONObjectWithData(responseData, options: nil, error: nil) as? NSDictionary, let statuses = result["statuses"] as? [NSDictionary] {

                var tweets = statuses.map { TweetModel.createFromTweetObject($0) }
                var users = statuses.map { UserModel.createFromUserObject( $0["user"] as! NSDictionary) }

                completion(tweets, users)
            } else {
                //add throw for Swift 2.0
                completion([], [])
            }
        })
    }
    
    func getUser(username: String, completion: (UserModel?)->Void) {
        
        let parameters: [String: String] = [
            "screen_name": username,
            "include_entities": "0"
        ]
        
        let request = SLRequest(
            forServiceType: SLServiceTypeTwitter,
            requestMethod: SLRequestMethod.GET,
            URL: NSURL(string: "https://api.twitter.com/1.1/users/show.json")!,
            parameters: parameters
        )
        
        println(request.URL.absoluteString)
        
        request.account = account
        request.performRequestWithHandler({responseData, urlResponse, error in
            if let error = error {
                println("error making request: \(error)")
                return
            }
            
            if let result = NSJSONSerialization.JSONObjectWithData(responseData, options: nil, error: nil) as? NSDictionary {
                println(result)
                completion( UserModel.createFromUserObject(result) )
            } else {
                //add throw for Swift 2.0
                completion(nil)
            }
        })

    }

    func isFollowingUser(username: String, completion: (Bool)->Void) {
        let parameters: [String: String] = [
            "target_screen_name": username,
            "source_screen_name": account!.username
        ]
        
        let request = SLRequest(
            forServiceType: SLServiceTypeTwitter,
            requestMethod: SLRequestMethod.POST,
            URL: NSURL(string: "https://api.twitter.com/1.1/friendships/show.json")!,
            parameters: parameters
        )
        
        println(request.URL.absoluteString)
        
        request.account = account
        request.performRequestWithHandler({responseData, urlResponse, error in
            if let error = error {
                println("error making request: \(error)")
                return
            }
            
            if let result = NSJSONSerialization.JSONObjectWithData(responseData, options: nil, error: nil) as? NSDictionary,
                let relationship = result["relationship"] as? NSDictionary,
                let target = relationship["target"] as? NSDictionary,
                let following = target["following"] as? Bool where following == true {

                completion(true)
            } else {
                //add throw for Swift 2.0
                completion(false)
            }
        })

    }
    
    func followUser(username: String, completion: (Bool)->Void) {
        let parameters: [String: String] = [
            "screen_name": username,
            "follow": "1"
        ]
        
        let request = SLRequest(
            forServiceType: SLServiceTypeTwitter,
            requestMethod: SLRequestMethod.POST,
            URL: NSURL(string: "https://api.twitter.com/1.1/friendships/create.json")!,
            parameters: parameters
        )
        
        println(request.URL.absoluteString)
        
        request.account = account
        request.performRequestWithHandler({responseData, urlResponse, error in
            if let error = error {
                println("error making request: \(error)")
                return
            }
            
            if let result = NSJSONSerialization.JSONObjectWithData(responseData, options: nil, error: nil) as? NSDictionary {
                println(result)
                completion(true)
            } else {
                //add throw for Swift 2.0
                completion(false)
            }
        })
    }
    
}
