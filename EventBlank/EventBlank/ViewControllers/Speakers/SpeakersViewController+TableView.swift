//
//  SpeakersViewController+TableView.swift
//  EventBlank
//
//  Created by Marin Todorov on 9/21/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit

//MARK: - table view methods
extension SpeakersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return speakers.currentItems.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = speakers.currentItems[section]
        return section[section.keys.first!]!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("SpeakerCell") as! SpeakerCell
        
        //eg guard
        if indexPath.section >= speakers.currentItems.count {
            return cell
        }
        
        let section = speakers.currentItems[indexPath.section]
        let row = section[section.keys.first!]![indexPath.row]
        
        let userImage = row[Speaker.photo]?.imageValue ?? UIImage(named: "empty")!
        userImage.asyncToSize(.FillSize(cell.userImage.bounds.size), cornerRadius: cell.userImage.bounds.size.width/2, completion: {result in
            cell.userImage.image = result
        })
        
        cell.nameLabel.text = row[Speaker.name]
        if let twitter = row[Speaker.twitter] where count(twitter) > 0 {
            cell.twitterLabel.text = twitter.hasPrefix("@") ? twitter : "@"+twitter
        } else {
            cell.twitterLabel.text = ""
        }
        cell.btnToggleIsFavorite.selected = speakers.isFavorite(speakerId: row[Speaker.idColumn])
        
        cell.indexPath = indexPath
        cell.didSetIsFavoriteTo = {setIsFavorite, indexPath in
            //TODO: update all this to Swift 2.0
            let isInFavorites = self.speakers.isFavorite(speakerId: row[Speaker.idColumn])
            
            if setIsFavorite && !isInFavorites {
                self.speakers.addFavorite(speakerId: row[Speaker.idColumn])
            } else if !setIsFavorite && isInFavorites {
                self.speakers.removeFavorite(speakerId: row[Speaker.idColumn])
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let section = speakers.currentItems[indexPath.section]
        lastSelectedSpeaker = section[section.keys.first!]![indexPath.row]
        return indexPath
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        lastSelectedSpeaker = nil
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        
        if speakers.currentItems.count < 4 {
            return []
        } else {
            return speakers.currentItems.map {$0.keys.first!}
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return (section == speakers.currentItems.count - 1) ?
            /* leave enough space to expand under the tab bar */ ((UIApplication.sharedApplication().windows.first! as! UIWindow).rootViewController as! UITabBarController).tabBar.frame.size.height :
            /* no space between sections */ 0
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return (section == speakers.currentItems.count - 1) ? UIView() : nil
    }
}
