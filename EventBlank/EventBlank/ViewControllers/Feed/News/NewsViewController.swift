//
//  ViewController.swift
//  Twitter_test
//
//  Created by Marin Todorov on 6/18/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import Social
import Accounts
import RealmSwift
import XLPagerTabStrip

class NewsViewController: TweetListViewController {
    
    let newsCtr = NewsController()
    let userCtr = UserController()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        observeNotification(kTabItemSelectedNotification, selector: "didTapTabItem:")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        observeNotification(kTabItemSelectedNotification, selector: nil)
    }
    
    func didTapTabItem(notification: NSNotification) {
        if let index = notification.userInfo?["object"] as? Int where index == EventBlankTabIndex.Feed.rawValue {
            mainQueue({
              if self.tweets.count > 0 {
                self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
              }
            })
        }
    }
    
    // MARK: table view methods
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("TweetCell") as! TweetCell
        let row = indexPath.row

        let tweet = self.tweets[indexPath.row]
        
        cell.database = database
        
        //populate
        cell.populateFromNewsTweet(tweet)
        
        //tap handlers
        if let attachmentUrlString = tweet[News.imageUrl], let attachmentUrl = NSURL(string: attachmentUrlString) {
            cell.didTapAttachment = {
                PhotoPopupView.showImageWithUrl(attachmentUrl, inView: self.view)
            }
        }
        cell.didTapURL = {tappedUrl in
            if tappedUrl.absoluteString!.hasPrefix("http") {
                let webVC = self.storyboard?.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
                webVC.initialURL = tappedUrl
                self.navigationController!.pushViewController(webVC, animated: true)
            } else {
                UIApplication.sharedApplication().openURL(tappedUrl)
            }
        }
        
        return cell
    }
    
    // MARK: load/fetch data
    
    override func loadTweets() {
        //fetch latest tweets from db
        let latestText = tweets.first?[News.news]
        
        tweets = self.newsCtr.allNews()
        lastRefresh = NSDate().timeIntervalSince1970
        
        if latestText == tweets.first?[News.news] {
            //latest tweet is the same, bail
            return;
        }
        
        //reload table
        mainQueue {
            self.tableView.reloadData()
            
            if self.tweets.count == 0 {
                self.tableView.addSubview(MessageView(text: "No tweets found at this time, try again later"))
            } else {
                MessageView.removeViewFrom(self.tableView)
            }
        }
    }

    override func fetchTweets() {
        twitter.authorize({success in
            MessageView.removeViewFrom(self.tableView)
            
            if success {
                self.twitter.getTimeLineForUsername(Event.event[Event.twitterAdmin]!, completion: {tweetList, user in
                    if let user = user where tweetList.count > 0 {
                        self.userCtr.persistUsers([user])
                        self.newsCtr.persistNews(tweetList)
                        self.loadTweets()
                    }
                })
            } else {
                delay(seconds: 0.5, {
                    self.tableView.addSubview(
                        //show a message + button to settings
                        MessageView(text: "You don't have Twitter accounts set up. Open Settings app, select Twitter and connect an account. \n\nThen pull this view down to refresh the feed."
//TODO: add the special iOS9 settings links later
//                            ,buttonTitle: "Open Settings App",
//                            buttonTap: {
//                                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
//                            }
                        ))
                })
            }
            
            mainQueue { self.refreshView.endRefreshing() }
        })
    }
}

