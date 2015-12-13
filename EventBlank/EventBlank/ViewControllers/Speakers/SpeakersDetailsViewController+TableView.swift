//
//  SpeakersDetailsViewController+TableView.swift
//  EventBlank
//
//  Created by Marin Todorov on 9/22/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import RealmSwift

//MARK: table view methods

extension SpeakerDetailsViewController {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let twitterHandle = speaker[Speaker.twitter] where count(twitterHandle) > 0 {
            return 2
        }
        return 1
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
            
            //configure
            cell.isFavoriteSpeaker = speakers.isFavorite(speakerId: speaker[Speaker.idColumn])
            cell.indexPath = indexPath

            //populate
            cell.populateFromSpeaker(speaker, twitter: twitter)
            
            //tap handlers
            if let twitterHandle = speaker[Speaker.twitter] where count(twitterHandle) > 0 {
                cell.didTapTwitter = {
                    let twitterUrl = NSURL(string: "https://twitter.com/" + twitterHandle)!
                    
                    let webVC = self.storyboard?.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
                    webVC.initialURL = twitterUrl
                    self.navigationController!.pushViewController(webVC, animated: true)
                }
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
            }
            cell.didSetIsFavoriteTo = {setIsFavorite, indexPath in
                //TODO: update all this to Swift 2.0
                let id = self.speaker[Speaker.idColumn]
                
                let isInFavorites = self.speakers.isFavorite(speakerId: id)
                if setIsFavorite && !isInFavorites {
                    self.speakers.addFavorite(speakerId: id)
                } else if !setIsFavorite && isInFavorites {
                    self.speakers.removeFavorite(speakerId: id)
                }
                
                delay(seconds: 0.1, {
                    self.notification(kFavoritesChangedNotification, object: self.speakers)
                })
            }
            cell.didTapURL = {tappedUrl in
                let webVC = self.storyboard?.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
                webVC.initialURL = tappedUrl
                self.navigationController!.pushViewController(webVC, animated: true)
            }

            //work on the user photo
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
                        PhotoPopupView.showImage(self.speaker[Speaker.photo]!.imageValue!, inView: self.view)
                    }
                }
            })
            
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
    
}
