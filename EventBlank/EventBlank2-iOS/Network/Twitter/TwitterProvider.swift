//
//  TwitterProvider.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 3/2/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import Foundation
import Social
import Accounts

import RxSwift
import SwiftyJSON

private extension String {
    var URLEscapedString: String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
    }
}

class TwitterProvider {
    struct Errors {
        static let domain = "TwitterProvider"
        static let authorizationFailed = 1
        static let malformedResponse = 2
    }
    
    let backgroundWorkScheduler: ImmediateSchedulerType
    
    init() {
        let operationQueue = NSOperationQueue()
        operationQueue.maxConcurrentOperationCount = 2
        operationQueue.qualityOfService = NSQualityOfService.UserInitiated
        backgroundWorkScheduler = OperationQueueScheduler(operationQueue: operationQueue)
    }
    
    func currentAccount() -> Observable<ACAccount> {
        return Observable.create { observer in
            
            let accountStore = ACAccountStore()
            let accountType  = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
            
            accountStore.requestAccessToAccountsWithType(accountType, options: nil, completion: {success, error in
                if let twitterAccount = accountStore.accountsWithAccountType(accountType).first as? ACAccount {
                    observer.onNext(twitterAccount)
                    observer.onCompleted()
                } else {
                    observer.onCompleted()
                }
            })
            
            return NopDisposable.instance
        }
        .observeOn(MainScheduler.instance)
    }
    
    func isFollowingUser(account: ACAccount, username: String) -> Observable<FollowingOnTwitter> {
        //prepare social network request
        let parameters: [String: String] = [
            "target_screen_name": username,
            "source_screen_name": account.username
        ]
        
        let request = SLRequest(
            forServiceType: SLServiceTypeTwitter,
            requestMethod: SLRequestMethod.GET,
            URL: NSURL(string: "https://api.twitter.com/1.1/friendships/show.json")!,
            parameters: parameters
        )
        
        request.account = account
        
        //send of url request
        let urlRequest = request.preparedURLRequest()
        
        //observe response
        return NSURLSession.sharedSession()
            .rx_response(urlRequest)
            .retry(3)
            .observeOn(backgroundWorkScheduler)
            .map { data, httpResponse -> FollowingOnTwitter in
                if httpResponse.statusCode == 403 {
                    return .NA
                }
                
                let json = JSON(data: data)
                
                let following = json["relationship"]["source"]["following"]
                guard following.isExists() else {
                    return .NotFollowing(username)
                }
                
                return .Following(username)
            }
            .observeOn(MainScheduler.instance)
            .retryOnBecomesReachable(.NA, reachabilityService: ReachabilityService.sharedReachabilityService)
    }
}