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

import RxSwift
import SwiftyJSON

class TwitterController111 {
//    
//    struct Errors {
//        static let domain = "TwitterController"
//        static let authorizationFailed = 1
//        static let malformedResponse = 2
//    }
//
//    let backgroundWorkScheduler: ImmediateSchedulerType
//    
//    init() {
//        let operationQueue = NSOperationQueue()
//        operationQueue.maxConcurrentOperationCount = 2
//        operationQueue.qualityOfService = NSQualityOfService.UserInitiated
//        backgroundWorkScheduler = OperationQueueScheduler(operationQueue: operationQueue)
//    }
//    
//    func currentAccount() -> Observable<ACAccount> {
//        return Observable.create { observer in
//            
//            let accountStore = ACAccountStore()
//            let accountType  = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
//
//            accountStore.requestAccessToAccountsWithType(accountType, options: nil, completion: {success, error in
//                if let twitterAccount = accountStore.accountsWithAccountType(accountType).first as? ACAccount {
//                    observer.onNext(twitterAccount)
//                    observer.onCompleted()
//                } else {
//                    observer.onCompleted()
//                }
//            })
//            
//            return NopDisposable.instance
//        }
//        .observeOn(MainScheduler.instance)
//    }
//    
//    func isFollowingUser(account: ACAccount, username: String) -> Observable<FollowingOnTwitter> {
//        //prepare social network request
//        let parameters: [String: String] = [
//            "target_screen_name": username,
//            "source_screen_name": account.username
//        ]
//
//        let request = SLRequest(
//            forServiceType: SLServiceTypeTwitter,
//            requestMethod: SLRequestMethod.GET,
//            URL: NSURL(string: "https://api.twitter.com/1.1/friendships/show.json")!,
//            parameters: parameters
//        )
//
//        request.account = account
//        
//        //send of url request
//        let urlRequest = request.preparedURLRequest()
//        
//        //observe response
//        return NSURLSession.sharedSession()
//            .rx_response(urlRequest)
//            .retry(3)
//            .observeOn(backgroundWorkScheduler)
//            .map { data, httpResponse -> FollowingOnTwitter in
//                if httpResponse.statusCode == 403 {
//                    return .NA
//                }
//                
//                let json = JSON(data: data)
//                
//                let following = json["relationship"]["source"]["following"]
//                guard following.isExists() else {
//                    return .NotFollowing
//                }
//                
//                return .Following
//            }
//            .retryOnBecomesReachable(.NA, reachabilityService: ReachabilityService.sharedReachabilityService)
//    }
    
//    func authorize(completion: (Bool)->Void) {
//        
//        let accountStore = ACAccountStore()
//        let accountType  = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
//        
//        accountStore.requestAccessToAccountsWithType(accountType, options: nil, completion: {success, error in
//            if let twitterAccount = accountStore.accountsWithAccountType(accountType).first as? ACAccount {
//                self.account = twitterAccount
//                mainQueue({ completion(true) })
//            } else {
//                //add throws in Swift 2.0
//                mainQueue({ completion(false) })
//            }
//        })
//    }
    
//    func getTimeLineForUsername(username: String, completion: ([TweetModel], UserModel?)->Void) {
//        
//        let parameters: [String: String] = [
//            "screen_name" : username.hasPrefix("@") ? username : "@"+username,
//            "include_rts" : "0",
//            "trim_user" : "0",
//            "count" : "20"]
//        
//        let request = SLRequest(
//            forServiceType: SLServiceTypeTwitter,
//            requestMethod: SLRequestMethod.GET,
//            URL: NSURL(string: "https://api.twitter.com/1.1/statuses/user_timeline.json")!,
//            parameters: parameters
//        )
//        
//        request.account = account
//        request.performRequestWithHandler({responseData, urlResponse, error in
//            if let error = error {
//                println("error making request: \(error)")
//                completion([], nil)
//                return
//            }
//            
//            if let results = NSJSONSerialization.JSONObjectWithData(responseData, options: nil, error: nil) as? [NSDictionary] {
//                var tweets = results.map {TweetModel.createFromTweetObject($0)}
//                var user = results.map { UserModel.createFromUserObject( $0["user"] as! NSDictionary) }.first
//                
//                completion(tweets, user)
//            } else {
//                //add throw for Swift 2.0
//                completion([], nil)
//            }
//        })
//    }
//
//    func getImageWithUrl(imageUrl: NSURL, completion: (UIImage?)->Void) {
//        let task = NSURLSession.sharedSession().downloadTaskWithURL(imageUrl, completionHandler: {url, response, error in
//            if error == nil, let data = NSData(contentsOfURL: url), let image = UIImage(data: data) {
//                completion(image)
//            } else {
//                println("download error: \(error)")
//                completion(nil)
//            }
//        })
//        task.resume()
//    }
//    
//    func getSearchForTerm(term: String, completion: ([TweetModel], [UserModel])->Void) {
//        
//        let parameters: [String: String] = [
//            "q": term,
////            "result_type": "all",
//            "trim_user": "0",
//            "count": "20"]
//        
//        let request = SLRequest(
//            forServiceType: SLServiceTypeTwitter,
//            requestMethod: SLRequestMethod.GET,
//            URL: NSURL(string: "https://api.twitter.com/1.1/search/tweets.json")!,
//            parameters: parameters
//        )
//        
//        request.account = account
//        request.performRequestWithHandler({responseData, urlResponse, error in
//            if let error = error {
//                println("error making request: \(error)")
//                return
//            }
//            
//            if let result = NSJSONSerialization.JSONObjectWithData(responseData, options: nil, error: nil) as? NSDictionary, let statuses = result["statuses"] as? [NSDictionary] {
//
//                var tweets = statuses.map { TweetModel.createFromTweetObject($0) }
//                var users = statuses.map { UserModel.createFromUserObject( $0["user"] as! NSDictionary) }
//
//                completion(tweets, users)
//            } else {
//                //add throw for Swift 2.0
//                completion([], [])
//            }
//        })
//    }
//    
//    func getUser(username: String, completion: (UserModel?)->Void) {
//        
//        let parameters: [String: String] = [
//            "screen_name": username,
//            "include_entities": "0"
//        ]
//        
//        let request = SLRequest(
//            forServiceType: SLServiceTypeTwitter,
//            requestMethod: SLRequestMethod.GET,
//            URL: NSURL(string: "https://api.twitter.com/1.1/users/show.json")!,
//            parameters: parameters
//        )
//        
//        request.account = account
//        request.performRequestWithHandler({responseData, urlResponse, error in
//            if let error = error {
//                println("error making request: \(error)")
//                return
//            }
//            
//            if let result = NSJSONSerialization.JSONObjectWithData(responseData, options: nil, error: nil) as? NSDictionary {
//                completion( UserModel.createFromUserObject(result) )
//            } else {
//                //add throw for Swift 2.0
//                completion(nil)
//            }
//        })
//
//    }
//
//    func isFollowingUser(username: String, completion: (Bool?)->Void) {
//        let parameters: [String: String] = [
//            "target_screen_name": username,
//            "source_screen_name": account!.username
//        ]
//        
//        let request = SLRequest(
//            forServiceType: SLServiceTypeTwitter,
//            requestMethod: SLRequestMethod.GET,
//            URL: NSURL(string: "https://api.twitter.com/1.1/friendships/show.json")!,
//            parameters: parameters
//        )
//        
//        request.account = account
//        request.performRequestWithHandler({responseData, urlResponse, error in
//            if let error = error {
//                println("error making request: \(error)")
//                completion(nil)
//                return
//            }
//            
//            let r = NSJSONSerialization.JSONObjectWithData(responseData, options: nil, error: nil) as? NSDictionary
//            
//            if let result = NSJSONSerialization.JSONObjectWithData(responseData, options: nil, error: nil) as? NSDictionary,
//                let relationship = result["relationship"] as? NSDictionary,
//                let target = relationship["source"] as? NSDictionary,
//                let following = target["following"] as? Bool where following == true {
//
//                completion(true)
//            } else {
//                //add throw for Swift 2.0
//                completion(false)
//            }
//        })
//
//    }
//    
//    func followUser(username: String, completion: (Bool)->Void) {
//        let parameters: [String: String] = [
//            "screen_name": username
//        ]
//        
//        let request = SLRequest(
//            forServiceType: SLServiceTypeTwitter,
//            requestMethod: SLRequestMethod.POST,
//            URL: NSURL(string: "https://api.twitter.com/1.1/friendships/create.json")!,
//            parameters: parameters
//        )
//        
//        request.account = account
//        request.performRequestWithHandler({responseData, urlResponse, error in
//            if let error = error {
//                println("error making request: \(error)")
//                return
//            }
//            
//            if let result = NSJSONSerialization.JSONObjectWithData(responseData, options: nil, error: nil) as? NSDictionary {
//                completion(true)
//            } else {
//                //add throw for Swift 2.0
//                completion(false)
//            }
//        })
//    }
    
}
