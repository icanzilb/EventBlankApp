//
//  ChatViewController.swift
//  Twitter_test
//
//  Created by Marin Todorov on 6/18/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import SQLite
import XLPagerTabStrip
import Haneke

class ChatViewController: TweetListViewController {

    let chatCtr = ChatController()
    let userCtr = UserController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        observeNotification(kDidPostTweetNotification, selector: "fetchTweets")
    }

    deinit {
        observeNotification(kDidPostTweetNotification, selector: nil)
    }
    
    //MARK: - table view methods
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("TweetCell") as! TweetCell
        let row = indexPath.row
        
        let tweet = self.tweets[indexPath.row]
        
        let usersTable = database[UserConfig.tableName]
        let user = usersTable.filter(User.idColumn == tweet[Chat.idUser]).first
        
        cell.message.text = tweet[Chat.message]
        cell.timeLabel.text = NSDate(timeIntervalSince1970: Double(tweet[Chat.created])).relativeTimeToString()
        cell.message.selectedRange = NSRange(location: 0, length: 0)
        
        if let attachmentUrlString = tweet[Chat.imageUrl], let attachmentUrl = NSURL(string: attachmentUrlString) {
            cell.attachmentImage.hnk_setImageFromURL(attachmentUrl)
            cell.didTapAttachment = {
                PhotoPopupView.showImageWithUrl(attachmentUrl, inView: self.view)
            }
            cell.attachmentHeight.constant = 148.0
        }
        
        if let user = user {
            cell.nameLabel.text = user[User.name]
            if let imageUrlString = user[User.photoUrl], let imageUrl = NSURL(string: imageUrlString) {
                cell.userImage.hnk_setImageFromURL(imageUrl, placeholder: UIImage(named: "feed-item"))
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

    //MARK: - fetching data
    
    override func loadTweets() {
        tweets = self.chatCtr.allMessages()
        lastRefresh = NSDate().timeIntervalSince1970
        
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
            
            if success, var hashTag = Event.event[Event.twitterTag] {

                self.notification(kTwitterAuthorizationChangedNotification, object: true)
                
                if !hashTag.hasPrefix("#") {
                    hashTag = "#\(hashTag)"
                }
                
                self.twitter.getSearchForTerm(hashTag, completion: {tweetList, userList in

                    self.userCtr.persistUsers(userList)
                    self.chatCtr.persistMessages(tweetList)
                    
                    let lastSavedId = self.tweets.first?[Chat.idColumn]
                    let lastFetchedId = tweetList.first?.id
                    
                    if lastSavedId != lastFetchedId {
                        self.loadTweets()
                    }
                })
            } else {
                
                self.notification(kTwitterAuthorizationChangedNotification, object: false)
                
                delay(seconds: 0.5, {
                    self.tableView.addSubview(MessageView(text: "You don't have Twitter accounts set up. Open Settings app, select Twitter and connect an account. \n\nThen pull this view down to refresh the feed."))
                })
            }
            
            //hide the spinner
            mainQueue { self.refreshView.endRefreshing() }
        })
    }
    
}