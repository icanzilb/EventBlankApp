//
//  SessionsViewController+TableView.swift
//  EventBlank
//
//  Created by Marin Todorov on 9/22/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit

//MARK: table view methods
extension SessionsViewController {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = items[section]
        return section[section.keys.first!]!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SessionCell") as! SessionTableViewCell
        
        let section = items[indexPath.section]
        let session = section[section.keys.first!]![indexPath.row]

        //configure the cell
        cell.dateFormatter = dateFormatter
        cell.isFavoriteSession = (find(favorites, session[Session.idColumn]) != nil)
        cell.isFavoriteSpeaker = (find(speakerFavorites, session[Speaker.idColumn]) != nil)
        cell.indexPath = indexPath
        cell.mainColor = UIColor(hexString: event[Event.mainColor])
        
        //populate from session
        cell.populateFromSession(session)
        
        //tap handlers
        cell.didSetIsFavoriteTo = {setIsFavorite, indexPath in
            //TODO: update all this to Swift 2.0
            let isInFavorites = find(self.favorites, session[Session.idColumn]) != nil
            if setIsFavorite && !isInFavorites {
                Favorite.saveSessionId(session[Session.idColumn])
            } else if !setIsFavorite && isInFavorites {
                Favorite.removeSessionId(session[Session.idColumn])
            }
            self.notification(kFavoritesChangedNotification, object: nil)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let section = items[indexPath.section]
        lastSelectedSession = section[section.keys.first!]![indexPath.row]
        return indexPath
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        lastSelectedSession = nil
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //this section
        let nowSection = items[section]
        var nowSectionTitle = nowSection.keys.first!
        let nowSession = nowSection.values.first!.first!
        let nowSessionStartTime = nowSession[Session.beginTime]
        
        if currentSectionIndex == section - 1 {
            //next upcoming session
            return nowSectionTitle + " (coming up next)"
        }
        
        //next section
        if items.count > section+1 {
            
            let nextSection = items[section+1]
            let nextSession = nextSection.values.first!.first!
            let nextSessionStartTime = nextSession[Session.beginTime]
            
            let rightNow = NSDate().timeIntervalSince1970
            
            if Double(nowSessionStartTime) < rightNow && rightNow < Double(nextSessionStartTime) {
                //current session
                currentSectionIndex = section
                return nowSectionTitle + " (LIVE now)"
            }
        } else {
            //reset the current section index
            currentSectionIndex = nil
        }
        
        return nowSectionTitle
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return (section == items.count - 1) ?
            /* leave enough space to expand under the tab bar */ ((UIApplication.sharedApplication().windows.first! as! UIWindow).rootViewController as! UITabBarController).tabBar.frame.size.height :
            /* no space between sections */ 0
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return (section == items.count - 1) ? UIView() : nil
    }
    
}
