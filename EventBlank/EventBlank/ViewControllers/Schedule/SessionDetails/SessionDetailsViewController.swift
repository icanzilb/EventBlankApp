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
    
    var database: Database {
        return DatabaseProvider.databases[eventDataFileName]!
    }
    
    @IBOutlet weak var tableView: UITableView!
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load favorites
        favorites = Favorite.allSessionFavoritesIDs()
        
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        title = "Session details"
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

            let sessionDate = NSDate(timeIntervalSince1970: Double(session[Session.beginTime]))
            let time = dateFormatter.stringFromDate(sessionDate)
            
            cell.sessionTitleLabel.attributedText = NSAttributedString(
                string: "\(time) \(session[Session.title])",
                attributes: NSDictionary(object: UIFont.systemFontOfSize(22), forKey: NSFontAttributeName) as [NSObject : AnyObject])
            
            cell.trackTitleLabel.text = session[Track.track]
            
            if let twitter = session[Speaker.twitter] {
                cell.twitterLabel.text = twitter.hasPrefix("@") ? twitter : "@"+twitter
                cell.didTapTwitter = {
                    let twitterUrl = NSURL(string: "https://twitter.com/" + twitter)!
                    let webVC = self.storyboard?.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
                    webVC.initialURL = twitterUrl
                    self.navigationController!.pushViewController(webVC, animated: true)
                }
            } else {
                cell.twitterLabel.text = nil
                cell.didTapTwitter = nil
            }
            
            cell.websiteLabel.text = session[Speaker.url]
            cell.btnToggleIsFavorite.selected = find(favorites, session[Session.idColumn]) != nil
            cell.descriptionTextView.text = session[Session.description]
            
            let userImage = session[Speaker.photo]?.imageValue ?? UIImage(named: "empty")!
            userImage.asyncToSize(.FillSize(cell.userImage.bounds.size), cornerRadius: 5, completion: {result in
                cell.userImage.image = result
            })

            if session[Speaker.photo]?.imageValue != nil {
                cell.didTapPhoto = {
                    PhotoPopupView.showImage(cell.userImage.image!, inView: self.view)
                }
            }
            
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
                cell.speakerUrl = url
            } else {
                cell.speakerUrl = nil
            }

            cell.didTapURL = {tappedUrl in
                let webVC = self.storyboard?.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
                webVC.initialURL = tappedUrl
                self.navigationController!.pushViewController(webVC, animated: true)
            }
            
            //theme
            cell.sessionTitleLabel.textColor = UIColor(hexString: event[Event.mainColor])
            cell.trackTitleLabel.textColor = UIColor(hexString: event[Event.mainColor]).lightenColor(0.1).desaturatedColor()
            
            //check if in the past
            if NSDate().isLaterThanDate(sessionDate) {
                println("\(sessionDate) is in the past")
                cell.sessionTitleLabel.textColor = cell.sessionTitleLabel.textColor.desaturateColor(0.5).lighterColor()
                cell.trackTitleLabel.textColor = cell.sessionTitleLabel.textColor
            }
            
            return cell
        }
        
        fatalError("out of section bounds")
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}