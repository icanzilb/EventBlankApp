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
        return speakers.items.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = speakers.items[section]
        return 1//section[section.keys.first!]!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("SpeakerCell") as! SpeakerCell
        
        //eg guard
        if indexPath.section >= speakers.items.count {
            return cell
        }
        return cell;
        
//        let section = speakers.items[indexPath.section]
//        let speaker = section[section.keys.first!]![indexPath.row]
//        
//        //configure the cell
//        //cell.isFavoriteSpeaker = speakers.isFavorite(speakerId: speaker[Speaker.idColumn])
//        cell.indexPath = indexPath
//        
//        //populate
//        cell.populateFromSpeaker(speaker)
//        
//        //tap handlers
//        cell.didSetIsFavoriteTo = {setIsFavorite, indexPath in
//            //TODO: update all this to Swift 2.0
////            let isInFavorites = self.speakers.isFavorite(speakerId: speaker[Speaker.idColumn])
////            
////            if setIsFavorite && !isInFavorites {
////                self.speakers.addFavorite(speakerId: speaker[Speaker.idColumn])
////            } else if !setIsFavorite && isInFavorites {
////                self.speakers.removeFavorite(speakerId: speaker[Speaker.idColumn])
////            }
//        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        guard speakers.items.count < 4 else {
            return nil
        }
        return []
//        return speakers.items.map {$0.keys.first!}
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return (section == speakers.items.count - 1) ?
            /* leave enough space to expand under the tab bar */ ((UIApplication.sharedApplication().windows.first!).rootViewController as! UITabBarController).tabBar.frame.size.height :
            /* no space between sections */ 0
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return (section == speakers.items.count - 1) ? UIView() : nil
    }
}
