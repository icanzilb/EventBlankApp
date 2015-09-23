//
//  SpeakerDetailsViewController.swift
//  EventBlank
//
//  Created by Marin Todorov on 6/22/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import SQLite

class SpeakerDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var speaker: Row! //set from the previous view controller
    
    let twitter = TwitterController()
    var tweets: [TweetModel]? = nil
    
    let userCtr = UserController()
    
    @IBOutlet weak var tableView: UITableView!
    
    var user: Row?
    
    var database: Database {
        return DatabaseProvider.databases[appDataFileName]!
    }
    
    var speakers: SpeakersModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        //fetch new tweets
        if let twitterHandle = speaker[Speaker.twitter] where count(twitterHandle) > 0 {
            backgroundQueue(fetchTweets)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        title = speaker[Speaker.name]
    }
        
    //MARK: - fetching data
    
    func fetchTweets() {
        twitter.authorize({success in
            if success, let username = self.speaker[Speaker.twitter] {
                self.twitter.getTimeLineForUsername(username, completion: {tweetList, user in
                    if let user = user where tweetList.count > 0 {
                        self.userCtr.persistUsers([user])
                        self.didFetchTweets(tweetList)
                    } else {
                        self.tweets = []
                        mainQueue {
                            self.tableView.reloadSections(NSIndexSet(index: 1),
                                withRowAnimation: .Automatic)
                        }
                    }
                })
            } else {
                //TODO: no auth - show message?
                self.tweets = []
                mainQueue(self.tableView.reloadData)
            }
        })
    }
    
    func didFetchTweets(tweetList: [TweetModel]) {
        tweets = tweetList

        //reload table
        //TODO: remove delay when it's working
        delay(seconds: 0.1, {
            self.tableView.reloadSections(NSIndexSet(index: 1),
                withRowAnimation: UITableViewRowAnimation.Bottom)
        })
    }
    
    var fetchingUserImage = false
    
    func fetchUserImage() {
        
        fetchingUserImage = true
        
        if let imageUrlString = self.user![User.photoUrl],
            let imageUrl = NSURL(string: imageUrlString) {
                self.twitter.getImageWithUrl(imageUrl, completion: {image in

                    if let image = image, let user = self.user {
                        //update table cell
                        mainQueue({
                            self.userCtr.persistUserImage(image, userId: user[User.idColumn])
                            self.user = nil
                            self.fetchingUserImage = false
                            self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Automatic)
                        })
                    }
                })
        }
    }
    
}
