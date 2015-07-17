//
//  SessionsViewController.swift
//  EventBlank
//
//  Created by Marin Todorov on 6/20/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import SQLite
import XLPagerTabStrip

let kFavoritesToggledNotification = "kFavoritesToggledNotification"
let kFavoritesChangedNotification = "kFavoritesChangedNotification"

class SessionsViewController: UIViewController, XLPagerTabStripChildItem, UITableViewDataSource, UITableViewDelegate {

    var day: ScheduleDay! //set from container VC
    var items = [ScheduleDaySection]()
    var favorites = [Int]()
    
    var delegate: SessionViewControllerDelegate! //set from previous VC
    
    var database: Database {
        return DatabaseProvider.databases[eventDataFileName]!
        }
    
    var event: Row {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).event
    }
    
    let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.timeStyle = .ShortStyle
        formatter.dateFormat = .None
        return formatter
        }()
    
    var lastSelectedSession: Row?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        loadItems()
        
        observeNotification(kFavoritesToggledNotification, selector: "didToggleFavorites")
        observeNotification(kFavoritesChangedNotification, selector: "didToggleFavorites")
    }
    
    deinit {
        observeNotification(kFavoritesToggledNotification, selector: nil)
        observeNotification(kFavoritesChangedNotification, selector: nil)
    }
    
    func loadItems() {
        
        //load favorites
        favorites = Favorite.allSessionFavoritesIDs()
        
        //load sessions
        var sessions = database[SessionConfig.tableName]
            .join(database[SpeakerConfig.tableName], on: {Session.fk_speaker == Speaker.idColumn}())
            .join(database[TrackConfig.tableName], on: {Session.fk_track == Track.idColumn}())
            .join(database[LocationConfig.tableName], on: {Session.fk_location == Location.idColumn}())
            .filter(Session.beginTime > Int(day.startTimeStamp) && Session.beginTime < Int(day.endTimeStamp))
            .order(Session.beginTime.asc)
            .map {$0}
        
        //filter sessions
        if delegate.isFavoritesFilterOn() {
            sessions = sessions.filter({ session in
                return find(self.favorites, session[Session.idColumn]) != nil
            })
        }
        
        //build schedule sections
        items = Schedule().groupSessionsByStartTime(sessions)
        
        if items.count == 0 {
            tableView.addSubview(MessageView(text: "No sessions match your current filter"))
        } else {
            MessageView.removeViewFrom(tableView)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let detailsVC = segue.destinationViewController as? SessionDetailsViewController {
            detailsVC.session = lastSelectedSession
        }
    }
    
    // MARK: - XLPagerTabStripChildItem
    func titleForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController!) -> String! {
        return self.title
    }
    
    // MARK: - table view methods
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

        cell.titleLabel.text = session[Session.title]        
        cell.speakerLabel.text = session[Speaker.name]
        cell.trackLabel.text = session[Track.track]
        cell.timeLabel.text = dateFormatter.stringFromDate(
            NSDate(timeIntervalSince1970: Double(session[Session.beginTime]))
        )
        cell.speakerImageView.image = session[Speaker.photo]?.imageValue
        cell.locationLabel.text = session[Location.name]
        
        cell.btnToggleIsFavorite.selected = (find(favorites, session[Session.idColumn]) != nil)
        
        cell.indexPath = indexPath
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
        
        //theme
        cell.titleLabel.textColor = UIColor(hexString: event[Event.mainColor])
        cell.trackLabel.textColor = UIColor(hexString: event[Event.mainColor]).lightenColor(0.1).desaturatedColor()
        
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
        let section = items[section]
        return section.keys.first!
    }
    
    // MARK: - notifications
    func didToggleFavorites() {
        loadItems()
        UIView.transitionWithView(tableView, duration: 0.35, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            self.tableView.reloadData()
            }, completion: nil)
    }
}
