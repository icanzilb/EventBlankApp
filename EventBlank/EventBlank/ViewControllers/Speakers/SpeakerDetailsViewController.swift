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
    
    var user: Row?
    
    var database: Database {
        return DatabaseProvider.databases[appDataFileName]!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        //fetch new tweets
        backgroundQueue(fetchTweets)
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
            
            if let twitterHandle = speaker[Speaker.twitter] {
                cell.twitterLabel.text = twitterHandle.hasPrefix("@") ? twitterHandle : "@"+twitterHandle
                cell.didTapTwitter = {
                    let twitterUrl = NSURL(string: "https://twitter.com/" + twitterHandle)!
                    
                    let webVC = self.storyboard?.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
                    webVC.initialURL = twitterUrl
                    self.navigationController!.pushViewController(webVC, animated: true)
                }
                
                cell.btnIsFollowing.hidden = false
                cell.btnIsFollowing.username = cell.twitterLabel.text
                
                cell.didTapFollow = {
                    self.twitter.authorize({success in
                        if success {
                            cell.btnIsFollowing.followState = .SendingRequest
                            self.twitter.followUser(twitterHandle, completion: {following in
                                cell.btnIsFollowing.followState = following ? .Following : .Follow
                                cell.btnIsFollowing.animateSelect(scale: 0.8, completion: nil)
                            })
                        } else {
                            cell.btnIsFollowing.hidden = true
                        }
                    })
                }
                
                //check if already following speaker
                twitter.authorize({success in
                    if success {
                        self.twitter.isFollowingUser(twitterHandle, completion: {following in
                            if let following = following {
                                cell.btnIsFollowing.followState = following ? .Following : .Follow
                            } else {
                                cell.btnIsFollowing.hidden = true
                            }
                        })
                    } else {
                        cell.btnIsFollowing.hidden = true
                    }
                })
            } else {
                mainQueue {
                    cell.btnIsFollowing.hidden = true
                    cell.twitterLabel.text = ""
                    cell.didTapTwitter = nil
                }
            }

            cell.websiteLabel.text = speaker[Speaker.url]
            cell.btnToggleIsFavorite.selected = find(favorites, speaker[Speaker.idColumn]) != nil
            cell.bioTextView.text = speaker[Speaker.bio]
            let userImage = speaker[Speaker.photo]?.imageValue ?? UIImage(named: "empty")!
            userImage.asyncToSize(.FillSize(cell.userImage.bounds.size), cornerRadius: 5, completion: {result in
                cell.userImage.image = result
            })
            
            backgroundQueue({
                
                if self.speaker[Speaker.photo]?.imageValue == nil {
                    self.userCtr.lookupUserImage(self.speaker, completion: {userImage in
                        userImage?.asyncToSize(.FillSize(cell.userImage.bounds.size), cornerRadius: 5, completion: {result in
                            cell.userImage.image = result
                        })
                        if let userImage = userImage {
                            cell.didTapPhoto = {
                                PhotoPopupView.showImage(userImage, inView: self.view)
                            }
                        }
                    })
                } else {
                    cell.didTapPhoto = {
                        PhotoPopupView.showImage(cell.userImage.image!, inView: self.view)
                    }
                }
            })
            
            
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
                cell.speakerUrl = url
            } else {
                cell.speakerUrl = nil
            }
            
            cell.didTapURL = {tappedUrl in
                let webVC = self.storyboard?.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
                webVC.initialURL = tappedUrl
                self.navigationController!.pushViewController(webVC, animated: true)
            }
            
            return cell
        }
        
        if indexPath.section == 1, let tweets = tweets where tweets.count > 0 {
            
            let cell = self.tableView.dequeueReusableCellWithIdentifier("TweetCell") as! TweetCell
            let row = indexPath.row
            
            let tweet = tweets[indexPath.row]
            
            cell.message.text = tweet.text
            cell.timeLabel.text = tweet.created.relativeTimeToString()
            cell.message.selectedRange = NSRange(location: 0, length: 0)
            
            if let attachmentUrl = tweet.imageUrl {
                cell.attachmentImage.hnk_setImageFromURL(attachmentUrl, placeholder: nil, format: nil, failure: nil, success: {image in
                    image.asyncToSize(.Fill(cell.attachmentImage.bounds.width, 150), cornerRadius: 5.0, completion: {result in
                        cell.attachmentImage.image = result
                    })
                })
                cell.didTapAttachment = {
                    PhotoPopupView.showImageWithUrl(attachmentUrl, inView: self.view)
                }
                cell.attachmentHeight.constant = 148.0
            }
            
            cell.nameLabel.text = speaker[Speaker.name]
            
            if user == nil {
                let usersTable = database[UserConfig.tableName]
                user = usersTable.filter(User.idColumn == tweet.userId).first
            }
            
            if let userImage = user?[User.photo]?.imageValue {
                userImage.asyncToSize(.FillSize(cell.userImage.bounds.size), cornerRadius: 5, completion: {result in
                    cell.userImage.image = result
                })
            } else {
                if !fetchingUserImage {
                    fetchUserImage()
                }
                cell.userImage.image = UIImage(named: "empty")
            }
            
            cell.didTapURL = {tappedUrl in
                let webVC = self.storyboard?.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
                webVC.initialURL = tappedUrl
                self.navigationController!.pushViewController(webVC, animated: true)
            }

            return cell
        }
        
        if indexPath.section == 1 && tweets == nil {
            return tableView.dequeueReusableCellWithIdentifier("LoadingCell") as! UITableViewCell
        }
        
        return tableView.dequeueReusableCellWithIdentifier("") as! UITableViewCell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Speaker Details"
        case 1: return (tweets?.count < 1) ? "No tweets available" : "Latest tweets"
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
    
    //add some space at the end of the tweet list
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 1: return 50
        default: return 0
        }
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch section {
        case 1: return UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        default: return nil
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
                        mainQueue {
                            self.tableView.reloadSections(NSIndexSet(index: 1),
                                withRowAnimation: .Automatic)
                        }
                    }
                })
            } else {
                //TODO: no auth - show message?
                self.tweets = []
                mainQueue({ self.tableView.reloadData() })
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
