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
    
    var appData: Database {
        return DatabaseProvider.databases[appDataFileName]!
        }

    var database: Database {
        return DatabaseProvider.databases[eventDataFileName]!
    }
    
    typealias SpeakerSection = [String: [Row]]
    
    var items = [SpeakerSection]()
    var favorites = Favorite.allSpeakerFavoriteIDs()
    
    var lastSelectedSpeaker: Row?
    
    var btnFavorites = UIButton()

    var event: Row {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).event
    }

    //MARK: - view controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSpeakers()
        
        //notifications
        observeNotification(kFavoritesChangedNotification, selector: "didFavoritesChange")
        observeNotification(kDidReplaceEventFileNotification, selector: "didChangeEventFile")
    }
    
    deinit {
        observeNotification(kFavoritesChangedNotification, selector: nil)
        observeNotification(kDidReplaceEventFileNotification, selector: nil)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let _ = btnFavorites.superview where btnFavorites.hidden == true {
            btnFavorites.hidden = false
        }
        
        //set up the fav button
        btnFavorites.frame = CGRect(x: navigationController!.navigationBar.bounds.size.width - 40, y: 0, width: 40, height: 40)
        
        btnFavorites.setImage(UIImage(named: "like-empty")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
        btnFavorites.setImage(UIImage(named: "like-full")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Selected)
        btnFavorites.addTarget(self, action: Selector("actionToggleFavorites:"), forControlEvents: .TouchUpInside)
        btnFavorites.tintColor = UIColor.whiteColor()

        navigationController!.navigationBar.addSubview(btnFavorites)
        
        //add button background
        let gradient = CAGradientLayer()
        gradient.frame = btnFavorites.bounds
        gradient.colors = [UIColor(hexString: event[Event.mainColor]).colorWithAlphaComponent(0.1).CGColor, UIColor(hexString: event[Event.mainColor]).CGColor]
        gradient.locations = [0, 0.25]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        btnFavorites.layer.insertSublayer(gradient, below: btnFavorites.imageView!.layer)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        btnFavorites.hidden = true
    }
    
    func loadSpeakers() {
        items = []
        
        //load speakers
        var rows = database[SpeakerConfig.tableName].order(Speaker.name).map {$0}
        if btnFavorites.selected {
            rows = rows.filter({ (find(self.favorites, $0[Speaker.idColumn]) != nil) })
        }
        
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
        
        if items.count == 0 {
            tableView.hidden = true
            view.addSubview(MessageView(text: "You currently have no favorited speakers"))
        } else {
            tableView.hidden = false
            MessageView.removeViewFrom(view)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let speakerDetails = segue.destinationViewController as? SpeakerDetailsViewController {
            speakerDetails.speaker = lastSelectedSpeaker
            speakerDetails.favorites = favorites
        }
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
        if items.count < 4 {
            return []
        } else {
            return items.map {$0.keys.first!}
        }
    }
    
    //MARK: - favorites
    func didFavoritesChange() {
        favorites = Favorite.allSpeakerFavoriteIDs()
        loadSpeakers()
        tableView.reloadData()
    }
    
    //notifications
    func didChangeEventFile() {
        loadSpeakers()
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func actionToggleFavorites(sender: AnyObject) {
        btnFavorites.selected = !btnFavorites.selected
        btnFavorites.animateSelect(scale: 0.8, completion: {
            self.notification(kFavoritesToggledNotification, object: nil)

            self.loadSpeakers()
            UIView.transitionWithView(self.tableView, duration: 0.35, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                self.tableView.reloadData()
                }, completion: nil)
        })
    }

}
