//
//  SpeakersViewController.swift
//  Twitter_test
//
//  Created by Marin Todorov on 6/19/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

import RxSwift
import RxCocoa


class SpeakersViewController1: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var btnFavorites = UIButton()
    let searchController = UISearchController(searchResultsController:  nil)
    var speakers = SpeakersModel()
    
    typealias SpeakerSection = SectionModel<String, Speaker>
    
    var items: Observable<[SpeakerSection]> = just([])
    
    var disposeBag = DisposeBag()
    let dataSource = RxTableViewSectionedReloadDataSource<SpeakerSection>()
    
    //MARK: - view controller

    func loadSpeakers() {
//        speakers.refreshFavorites()
        
        let dataSource = self.dataSource
        
        speakers.load(searchTerm: searchController.searchBar.text!,
            showOnlyFavorites: btnFavorites.selected)
        
        dataSource.cellFactory = { (tv, indexPath, element) in
            let cell = tv.dequeueReusableCellWithIdentifier("SpeakerCell")!
            
            return cell
        }
        
        items = just(speakers.items)

        items
            .bindTo(tableView.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(disposeBag)
        
        if self.speakers.items.count == 0 {
            self.view.addSubview(MessageView(text: "You currently have no favorited speakers"))
        } else {
            MessageView.removeViewFrom(self.view)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSpeakers()
        
        
        
        if let _ = btnFavorites.superview where btnFavorites.hidden == true {
            btnFavorites.hidden = false
        }
        
        setupUI()
        
        if searchController.searchBar.text!.characters.count > 0 {
            //actionSearch(self)
        }
        
        //notifications
        observeNotification(kFavoritesChangedNotification, selector: "didFavoritesChange:")
        observeNotification(kDidReplaceEventFileNotification, selector: "didChangeEventFile")
    }

    deinit {
        observeNotification(kFavoritesChangedNotification, selector: nil)
        observeNotification(kDidReplaceEventFileNotification, selector: nil)
    }

    func setupUI() {
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
        gradient.colors = [UIColor(hexString: EventData.defaultEvent.mainColor).colorWithAlphaComponent(0.1).CGColor, UIColor(hexString: EventData.defaultEvent.mainColor).CGColor]
        gradient.locations = [0, 0.25]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        btnFavorites.layer.insertSublayer(gradient, below: btnFavorites.imageView!.layer)
        
        //search bar
//        searchController.searchResultsUpdater = self
//        searchController.delegate = self
//        searchController.searchBar.delegate = self
        
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        observeNotification(kTabItemSelectedNotification, selector: "didTapTabItem:")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        //search bar
        //didDismissSearchController(searchController)
        
        btnFavorites.hidden = true
        
        observeNotification(kTabItemSelectedNotification, selector: nil)
    }
    
    func didTapTabItem(notification: NSNotification) {
        if let index = notification.userInfo?["object"] as? Int where index == EventBlankTabIndex.Speakers.rawValue {
            mainQueue({
              if self.speakers.items.count > 0 {
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
//        if let speakerDetails = segue.destinationViewController as? SpeakerDetailsViewController {
//            speakerDetails.speaker = lastSelectedSpeaker
//            speakerDetails.speakers = speakers
//        }
//        
//        searchController.searchBar.endEditing(true)
    }
    
    //notifications
    func didChangeEventFile() {
        backgroundQueue(loadSpeakers, completion: {
            self.navigationController?.popToRootViewControllerAnimated(true)
            self.tableView.reloadData()
        })
    }
}