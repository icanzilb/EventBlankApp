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

    var searchController : UISearchController?
    
    //MARK: - view controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundQueue(loadSpeakers, completion: {
            self.tableView.reloadData()
        })

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
        btnFavorites.frame = CGRect(x: navigationController!.navigationBar.bounds.size.width - 40, y: 0, width: 40, height: 38)
        
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
        
        if let searchController = searchController {
            didDismissSearchController(searchController)
        }
    }
    
    func loadSpeakers() {
        loadSpeakers(nil)
    }
    
    func loadSpeakers(searchTerm: String?) {
        items = []
        
        //load speakers
        var rows = database[SpeakerConfig.tableName].order(Speaker.name).map {$0}
        if btnFavorites.selected {
            rows = rows.filter({ (find(self.favorites, $0[Speaker.idColumn]) != nil) })
        }
        
        if let searchTerm = searchTerm {
            rows = rows.filter({ ($0[Speaker.name]).contains(searchTerm, ignoreCase: true) })
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
        
        mainQueue({
            if self.items.count == 0 {
                self.tableView.hidden = true
                self.view.addSubview(MessageView(text: "You currently have no favorited speakers"))
            } else {
                self.tableView.hidden = false
                MessageView.removeViewFrom(self.view)
            }
        })
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
                mainQueue { cell.imageView?.image = image }
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
        mainQueue({ self.tableView.reloadData() })
        
    }
    
    //notifications
    func didChangeEventFile() {
        backgroundQueue(loadSpeakers, completion: {
            self.navigationController?.popToRootViewControllerAnimated(true)
            self.tableView.reloadData()
        })
    }
    
    func actionToggleFavorites(sender: AnyObject) {
        btnFavorites.selected = !btnFavorites.selected
        btnFavorites.animateSelect(scale: 0.8, completion: {
            self.notification(kFavoritesToggledNotification, object: nil)

            backgroundQueue(self.loadSpeakers, completion: {
                UIView.transitionWithView(self.tableView, duration: 0.35, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                    self.tableView.reloadData()
                    }, completion: nil)
            })
        })
    }

}

extension SpeakersViewController: UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {

    //how can a single class be so broken @UISearchController?
    
    @IBAction func actionSearch(sender: AnyObject) {
        //search
        searchController = UISearchController(searchResultsController:  nil)
        
        if let searchController = searchController {
            searchController.searchResultsUpdater = self
            searchController.delegate = self
            searchController.searchBar.delegate = self
            
            searchController.hidesNavigationBarDuringPresentation = false
            searchController.dimsBackgroundDuringPresentation = false
            
            definesPresentationContext = true
            
            searchController.searchBar.center = CGPoint(
                x: CGRectGetMinX(navigationController!.navigationBar.frame) + 4,
                y: CGRectGetMaxY(navigationController!.navigationBar.frame))
            
            navigationController!.navigationBar.addSubview(
                searchController.searchBar
            )
            
            btnFavorites.hidden = true
            navigationItem.prompt = "Speakers"
            navigationItem.leftBarButtonItem = nil
            
            searchController.searchBar.becomeFirstResponder()
        }
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        
        searchController.searchBar.resignFirstResponder()
        searchController.searchResultsUpdater = nil
        searchController.searchBar.delegate = nil
        searchController.delegate = nil
        self.searchController!.searchBar.removeFromSuperview()
        self.searchController = nil
        
        btnFavorites.hidden = false
        navigationItem.prompt = nil
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: "actionSearch:")
    }
    
    //search controller
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        backgroundQueue({ self.loadSpeakers(searchController.searchBar.text) },
            completion: { self.tableView.reloadData() })
    }
    
}


