//
//  SpeakersViewController.swift
//  Twitter_test
//
//  Created by Marin Todorov on 6/19/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import SQLite

class SpeakersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var appData: Database {
        return DatabaseProvider.databases[appDataFileName]!
        }

    var database: Database {
        return DatabaseProvider.databases[eventDataFileName]!
    }
    
    let speakers = SpeakersModel()

    var lastSelectedSpeaker: Row?
    var btnFavorites = UIButton()

    var event: Row {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).event
    }

    let searchController = UISearchController(searchResultsController:  nil)
    var initialized = false
    
    //MARK: - view controller
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundQueue(loadSpeakers)
    }
    
    func loadSpeakers() {
        speakers.load(searchTerm: searchController.searchBar.text,
            showOnlyFavorites: self.btnFavorites.selected)
        
        if self.tableView != nil {
            mainQueue({
                if self.speakers.currentNumberOfItems == 0 {
                    self.view.addSubview(MessageView(text: "You currently have no favorited speakers"))
                } else {
                    MessageView.removeViewFrom(self.view)
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        if !initialized {
            initialized = true
            
            if speakers.currentItems.count == 0 {
                backgroundQueue({ self.speakers.load() }, completion: {
                    self.tableView.reloadData()
                })
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
            
            //search bar
            searchController.searchResultsUpdater = self
            searchController.delegate = self
            searchController.searchBar.delegate = self
            
            searchController.hidesNavigationBarDuringPresentation = false
            searchController.dimsBackgroundDuringPresentation = false
            
            searchController.searchBar.center = CGPoint(
                x: CGRectGetMidX(navigationController!.navigationBar.frame) + 4,
                y: 20)
            searchController.searchBar.hidden = true

            //search controller is the worst
            let iOSVersion = NSString(string: UIDevice.currentDevice().systemVersion).doubleValue
            if iOSVersion < 9.0 {
                //position the bar on iOS8
                searchController.searchBar.center = CGPoint(
                    x: CGRectGetMinX(navigationController!.navigationBar.frame) + 4,
                    y: 20)
            }
            
            navigationController!.navigationBar.addSubview(
                searchController.searchBar
            )
        }
        
        if count(searchController.searchBar.text) > 0 {
            actionSearch(self)
        }
        
        observeNotification(kTabItemSelectedNotification, selector: "didTapTabItem:")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        //search bar
        didDismissSearchController(searchController)
        
        btnFavorites.hidden = true
        
        observeNotification(kTabItemSelectedNotification, selector: nil)
    }
    
    func didTapTabItem(notification: NSNotification) {
        if let index = notification.userInfo?["object"] as? Int where index == EventBlankTabIndex.Speakers.rawValue {
            mainQueue({
              if self.speakers.currentNumberOfItems > 0 {
                self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
              }
            })
        }
    }

    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        
        //search bar
        if parent == nil {
            searchController.searchBar.removeFromSuperview()
        }
    }
        
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let speakerDetails = segue.destinationViewController as? SpeakerDetailsViewController {
            speakerDetails.speaker = lastSelectedSpeaker
        }
        
        searchController.searchBar.endEditing(true)
    }
    
    //notifications
    func didChangeEventFile() {
        backgroundQueue(loadSpeakers, completion: {
            self.navigationController?.popToRootViewControllerAnimated(true)
            self.tableView.reloadData()
        })
    }
}