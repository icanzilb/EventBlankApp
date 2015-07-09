//
//  SessionDetailsViewController.swift
//  EventBlank
//
//  Created by Marin Todorov on 6/25/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import SQLite

class SessionDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var session: Row! //set from previous view controller
    var favorites = [Int]()
    
    let database: Database = {
        DatabaseProvider.databases[eventDataFileName]!
        }()
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var event: Row = {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).event
        }()
    
    override func viewDidLoad() {
        //load favorites
        favorites = Favorite.allSessionFavoritesIDs()
        
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        title = "Session details"
    }
    
    deinit {
        
    }
    
    //MARK: - table view methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            //speaker details
            
            let cell = tableView.dequeueReusableCellWithIdentifier("SessionDetailsCell") as! SessionDetailsCell
            
            cell.nameLabel.text = session[Speaker.name]
            cell.sessionTitleLabel.text = session[Session.title]
            cell.trackTitleLabel.text = session[Track.track]
            
            if let twitter = session[Speaker.twitter] {
                cell.twitterLabel.text = twitter.hasPrefix("@") ? twitter : "@"+twitter
                cell.didTapTwitter = {
                    UIApplication.sharedApplication().openURL(NSURL(string: "https://twitter.com/" + twitter)!)
                }
            } else {
                cell.twitterLabel.text = nil
                cell.didTapTwitter = nil
            }
            
            cell.websiteLabel.text = session[Speaker.url]
            cell.btnToggleIsFavorite.selected = find(favorites, session[Session.idColumn]) != nil
            cell.descriptionTextView.text = session[Session.description]
            cell.userImage.image = session[Speaker.photo]?.imageValue ?? UIImage(named: "empty")
            
            cell.indexPath = indexPath
            cell.didSetIsFavoriteTo = {setIsFavorite, indexPath in
                //TODO: update all this to Swift 2.0
                let id = self.session[Session.idColumn]
                
                let isInFavorites = find(self.favorites, id) != nil
                if setIsFavorite && !isInFavorites {
                    self.favorites.append(id)
                    Favorite.saveSessionId(id)
                } else if !setIsFavorite && isInFavorites {
                    self.favorites.removeAtIndex(find(self.favorites, id)!)
                    Favorite.removeSessionId(id)
                }
                
                self.notification(kFavoritesChangedNotification, object: nil)
            }
            
            if let urlString = session[Speaker.url], let url = NSURL(string: urlString) {
                cell.didTapURL = {
                    UIApplication.sharedApplication().openURL(url)
                }
            } else {
                cell.didTapURL = nil
            }
            
            //theme
            cell.sessionTitleLabel.textColor = UIColor(hexString: event[Event.mainColor])
            cell.trackTitleLabel.textColor = UIColor(hexString: event[Event.mainColor]).lightenColor(0.1).desaturatedColor()
            
            return cell
        }
        
        fatalError("out of section bounds")
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}