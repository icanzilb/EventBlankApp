//
//  SpeakersViewController.swift
//  Twitter_test
//
//  Created by Marin Todorov on 6/19/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import SQLite

class SpeakersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    let twitter = TwitterController()
    let userCtr = UserController()
    
    let appData: Database = {
        DatabaseProvider.databases[appDataFileName]!
        }()

    let database: Database = {
        DatabaseProvider.databases[eventDataFileName]!
        }()
    
    typealias SpeakerSection = [String: [Row]]
    
    var items = [SpeakerSection]()
    var favorites = Favorite.allSpeakerFavoriteIDs()
    
    var lastSelectedSpeaker: Row?
    
    //MARK: - view controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        items = []

        //load speakers
        let rows = database[SpeakerConfig.tableName].order(Speaker.name).map {$0}
        
        //order and group speakers
        var sectionUsers = [Row]()
        var lastUsedLetter = ""

        for speaker in rows {
            let firstNameCharacter = speaker[Speaker.name][0...0].uppercaseString
            
            if lastUsedLetter != "" && lastUsedLetter != firstNameCharacter {
                let newSectionTitle = lastUsedLetter
                let newSection: SpeakerSection = [newSectionTitle: sectionUsers]
                items.append(newSection)
                sectionUsers = []
            }
            
            sectionUsers.append(speaker)
            lastUsedLetter = firstNameCharacter
        }
        
        if sectionUsers.count > 0 {
            let newSectionTitle = lastUsedLetter
            let newSection: ScheduleDaySection = [newSectionTitle: sectionUsers]
            items.append(newSection)
        }
        
        observeNotification(kFavoritesChangedNotification, selector: "didFavoritesChange")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let speakerDetails = segue.destinationViewController as? SpeakerDetailsViewController {
            speakerDetails.speaker = lastSelectedSpeaker
            speakerDetails.favorites = favorites
        }
    }
    
    deinit {
        observeNotification(kFavoritesChangedNotification, selector: nil)
    }
    
    //MARK: - table view methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = items[section]
        return section[section.keys.first!]!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("SpeakerCell") as! SpeakerCell
        
        let section = items[indexPath.section]
        let row = section[section.keys.first!]![indexPath.row]
        
        cell.userImage.image = row[Speaker.photo]?.imageValue ?? UIImage(named: "empty")
        cell.nameLabel.text = row[Speaker.name]
        if let twitter = row[Speaker.twitter] {
            cell.twitterLabel.text = twitter.hasPrefix("@") ? twitter : "@"+twitter
        }
        cell.btnToggleIsFavorite.selected = (find(favorites, row[Speaker.idColumn]) != nil)
        
        if row[Speaker.photo]?.imageValue == nil {
            
            userCtr.lookupUserImage(row, completion: {image in
                dispatch_async(dispatch_get_main_queue(), {
                    cell.imageView?.image = image
                })
            })
            
        }
        
        cell.indexPath = indexPath
        cell.didSetIsFavoriteTo = {setIsFavorite, indexPath in
            //TODO: update all this to Swift 2.0
            let isInFavorites = find(self.favorites, row[Speaker.idColumn]) != nil
            if setIsFavorite && !isInFavorites {
                self.favorites.append(row[Speaker.idColumn])
                Favorite.saveSessionId(row[Speaker.idColumn])
            } else if !setIsFavorite && isInFavorites {
                self.favorites.removeAtIndex(find(self.favorites, row[Speaker.idColumn])!)
                Favorite.removeSessionId(row[Speaker.idColumn])
            }
        }
        
        return cell
    }

    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let section = items[indexPath.section]
        lastSelectedSpeaker = section[section.keys.first!]![indexPath.row]
        return indexPath
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        lastSelectedSpeaker = nil
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        return items.map {$0.keys.first!}
    }
    
    //MARK: - fetching data
    
    //MARK: - favorites
    func didFavoritesChange() {
        favorites = Favorite.allSpeakerFavoriteIDs()
        tableView.reloadData()
    }
}
