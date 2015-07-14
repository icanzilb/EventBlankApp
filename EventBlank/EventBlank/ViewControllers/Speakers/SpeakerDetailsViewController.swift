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
    var favorites: [Int]! //set from the previous view controller
    
    let twitter = TwitterController()
    var tweets: [TweetModel]? = nil
    
    let newsCtr = NewsController()
    let userCtr = UserController()
    
    @IBOutlet weak var tableView: UITableView!
    
    var database: Database {
        return DatabaseProvider.databases[appDataFileName]!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        //fetch new tweets
        fetchTweets()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        title = speaker[Speaker.name]
    }
    
    //MARK: - table view methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1;
            
        case 1 where tweets == nil: return 1
        case 1 where tweets != nil && tweets!.count == 0: return 0
        case 1 where tweets != nil && tweets!.count > 0: return tweets!.count
            
        default: return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            //speaker details
            
            let cell = tableView.dequeueReusableCellWithIdentifier("SpeakerDetailsCell") as! SpeakerDetailsCell
            
            cell.nameLabel.text = speaker[Speaker.name]
            
            if let twitter = speaker[Speaker.twitter] {
                cell.twitterLabel.text = twitter.hasPrefix("@") ? twitter : "@"+twitter
                cell.didTapTwitter = {
                    UIApplication.sharedApplication().openURL(NSURL(string: "https://twitter.com/" + twitter)!)
                }
            } else {
                cell.twitterLabel.text = nil
                cell.didTapTwitter = nil
            }

            cell.websiteLabel.text = speaker[Speaker.url]
            cell.btnToggleIsFavorite.selected = find(favorites, speaker[Speaker.idColumn]) != nil
            cell.bioTextView.text = speaker[Speaker.bio]
            cell.userImage.image = speaker[Speaker.photo]?.imageValue ?? UIImage(named: "empty")
            
            if speaker[Speaker.photo]?.imageValue == nil {
                
                userCtr.lookupUserImage(speaker, completion: {image in
                    dispatch_async(dispatch_get_main_queue(), {
                        cell.userImage.image = image
                    })
                })
            }
            
            cell.indexPath = indexPath
            cell.didSetIsFavoriteTo = {setIsFavorite, indexPath in
                //TODO: update all this to Swift 2.0
                let id = self.speaker[Speaker.idColumn]
                
                let isInFavorites = find(self.favorites, id) != nil
                if setIsFavorite && !isInFavorites {
                    self.favorites.append(id)
                    Favorite.saveSpeakerId(id)
                } else if !setIsFavorite && isInFavorites {
                    self.favorites.removeAtIndex(find(self.favorites, id)!)
                    Favorite.removeSpeakerId(id)
                }
                
                self.notification(kFavoritesChangedNotification, object: nil)
            }
            
            if let urlString = speaker[Speaker.url], let url = NSURL(string: urlString) {
                cell.didTapURL = {
                    UIApplication.sharedApplication().openURL(url)
                }
            } else {
                cell.didTapURL = nil
            }
            
            return cell
        }
        
        if indexPath.section == 1, let tweets = tweets where tweets.count > 0 {
            
            let cell = self.tableView.dequeueReusableCellWithIdentifier("TweetCell") as! TweetCell
            let row = indexPath.row
            
            let tweet = tweets[indexPath.row]
            
            let usersTable = database[UserConfig.tableName]
            let user = usersTable.filter(User.idColumn == tweet.userId).first

            cell.message.text = tweet.text
            cell.timeLabel.text = tweet.created.relativeTimeToString()
            cell.message.selectedRange = NSRange(location: 0, length: 0)
            
            if let attachmentUrl = tweet.imageUrl {
                cell.attachmentImage.hnk_setImageFromURL(attachmentUrl)
                cell.didTapAttachment = {
                    let webVC = self.storyboard?.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
                    webVC.initialURL = attachmentUrl
                    self.navigationController!.pushViewController(webVC, animated: true)
                }
                cell.attachmentHeight.constant = 148.0
            }
            
            if let user = user {
                cell.nameLabel.text = user[User.name]
                fetchUserImageForCell(cell, withUser: user)
            }
            
            return cell
        }
        
        if indexPath.section == 1 && tweets == nil {
            println("show loader")
            return tableView.dequeueReusableCellWithIdentifier("LoadingCell") as! UITableViewCell
        }
        
        return tableView.dequeueReusableCellWithIdentifier("") as! UITableViewCell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Speaker Details"
        case 1: return "Latest tweets"
        default: return nil
        }
    }
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1, let tweets = tweets where tweets.count == 0 {
            return "We couldn't load any tweets"
        } else {
            return nil
        }
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
                        dispatch_async(dispatch_get_main_queue(), {
                            self.tableView.reloadSections(NSIndexSet(index: 1),
                                withRowAnimation: .Automatic)
                        })
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        //self.refreshView.endRefreshing()
                    })
                })
            } else {
                //TODO: no auth - show message?
                println("auth error")
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
    
    func fetchUserImageForCell(cell: TweetCell, withUser user: Row) {
        
        if user[User.photo]?.imageValue == nil,
            let imageUrlString = user[User.photoUrl],
            let imageUrl = NSURL(string: imageUrlString) {
                
                self.twitter.getImageWithUrl(imageUrl, completion: {image in
                    //update table cell
                    dispatch_async(dispatch_get_main_queue(), {
                        cell.userImage.image = image
                    })
                })
        }
    }
    
}
