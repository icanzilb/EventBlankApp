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

let kRefreshViewHeight: CGFloat = 60.0

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, RefreshViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let chatCtr = ChatController()
    let userCtr = UserController()
    let twitter = TwitterController()
    var tweets = [Row]()

    var refreshView: RefreshView!
    
    let database: Database = {
        DatabaseProvider.databases[appDataFileName]!
        }()
    
    //MARK: - view controller methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSavedTweets()
        fetchTweets()
        
        setupUI()
    }
    
    func setupUI() {
        //setup table
        view.backgroundColor = UIColor.whiteColor()
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        //setup refresh view
        let refreshRect = CGRect(x: 0.0, y: -kRefreshViewHeight, width: view.frame.size.width, height: kRefreshViewHeight)
        refreshView = RefreshView(frame: refreshRect, scrollView: self.tableView)
        refreshView.delegate = self
        view.insertSubview(refreshView, aboveSubview: tableView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    //MARK: - table view methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
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
                let webVC = self.storyboard?.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
                webVC.initialURL = attachmentUrl
                self.navigationController!.pushViewController(webVC, animated: true)
            }
            cell.attachmentHeight.constant = 148.0
        }
        
        if let user = user {
            cell.nameLabel.text = user[User.name]
            if let imageUrlString = user[User.photoUrl], let imageUrl = NSURL(string: imageUrlString) {
                cell.userImage.hnk_setImageFromURL(imageUrl, placeholder: UIImage(named: "feed-item"))
            }
        }
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tweet = tweets[indexPath.row]
        if let urlString = tweet[News.url], let url = NSURL(string: urlString) {
            let webVC = storyboard?.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
            webVC.initialURL = url
            navigationController!.pushViewController(webVC, animated: true)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    //MARK: - fetching data
    
    func loadSavedTweets() {
        tweets = self.chatCtr.allMessages()
        
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
            
            if self.tweets.count == 0 {
                self.tableView.addSubview(MessageView(text: "No tweets found at this time, try again later"))
            } else {
                MessageView.removeViewFrom(self.tableView)
            }
        })
    }
    
    func fetchTweets() {
        twitter.authorize({success in
            MessageView.removeViewFrom(self.tableView)
            
            if success, let hashTag = Event.event[Event.twitterTag] {
                
                self.twitter.getSearchForTerm(Event.event[Event.twitterTag]!, completion: {tweetList, userList in

                    self.userCtr.persistUsers(userList)
                    self.chatCtr.persistMessages(tweetList)
                    
                    let lastSavedId = self.tweets.first?[Chat.idColumn]
                    let lastFetchedId = tweetList.first?.id
                    
                    if lastSavedId != lastFetchedId {
                        self.loadSavedTweets()
                    }
                })
            } else {
                delay(seconds: 0.5, {
                    self.tableView.addSubview(MessageView(text: "You don't have Twitter accounts set up. Open Preferences app, select Twitter and connect an account. \n\nThen pull this view down to refresh the feed."))
                })
            }
            
            //hide the spinner
            dispatch_async(dispatch_get_main_queue(), {
                self.refreshView.endRefreshing()
            })
        })
    }
    
    func refreshViewDidRefresh(refreshView: RefreshView) {
        fetchTweets()
    }

    func fetchUserImageForCell(cell: TweetCell, withUser user: Row, tweet: Row) {
        
        if user[User.photo]?.imageValue == nil,
            let imageUrlString = user[User.photoUrl],
            let imageUrl = NSURL(string: imageUrlString) {
                
                self.twitter.getImageWithUrl(imageUrl, completion: {image in
                    //add a guard image in Swift 2.0

                    if let image = image {
                        //save image
                        //self.chatCtr.persistImage(image, forTweetId: tweet[Chat.idColumn])
                        self.userCtr.persistUserImage(image, userId: user[User.idColumn])
                        
                        //update table cell
                        dispatch_async(dispatch_get_main_queue(), {
                            cell.userImage.image = image
                        })
                    }
                })
        }
    }
        
    // MARK: Scroll view methods
    func scrollViewDidScroll(scrollView: UIScrollView) {
        refreshView.scrollViewDidScroll(scrollView)
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        refreshView.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }

}
