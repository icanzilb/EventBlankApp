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

class SessionsViewController: UIViewController, XLPagerTabStripChildItem, UITableViewDataSource, UITableViewDelegate {
    
    var day: ScheduleDay! //set from container VC
    var items = [ScheduleDaySection]()
    
    var delegate: SessionViewControllerDelegate! //set from previous VC
    
    let schedule = Schedule()
  
    var event: Row {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).event
    }
    
    var currentSectionIndex: Int? = nil
    
    var lastSelectedSession: Row?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundQueue(loadItems, completion: self.tableView.reloadData)
        
        observeNotification(kFavoritesToggledNotification, selector: "didToggleFavorites")
        observeNotification(kFavoritesChangedNotification, selector: "didChangeFavorites")
        observeNotification(kScrollToCurrentSessionNotification, selector: "scrollToCurrentSession:")
        //observeNotification(kDidReplaceEventFileNotification, selector: "didChangeEventFile")
    }
    
    deinit {
        observeNotification(kFavoritesToggledNotification, selector: nil)
        observeNotification(kFavoritesChangedNotification, selector: nil)
        observeNotification(kScrollToCurrentSessionNotification, selector: nil)
        //observeNotification(kDidReplaceEventFileNotification, selector: nil)
    }
    
    func loadItems() {
        
        //build schedule sections
        schedule.refreshFavorites()
        items = schedule.sessionsByStartTime(day, onlyFavorites: delegate.isFavoritesFilterOn())
        
        mainQueue({
            //show no sessions message
            if self.items.count == 0 {
                self.tableView.addSubview(MessageView(text: "No sessions match your current filter"))
            } else {
                MessageView.removeViewFrom(self.tableView)
            }
        })
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
    
    // MARK: - notifications
    func didToggleFavorites() {
        backgroundQueue(loadItems, completion: self.tableView.reloadData)
    }
    
    func didChangeFavorites() {
        backgroundQueue(loadItems, completion: self.tableView.reloadData)
    }
    
    func didChangeEventFile() {
        backgroundQueue(loadItems, completion: self.tableView.reloadData)
    }
    
    func scrollToCurrentSession(n: NSNotification) {
        if let dayName = n.userInfo?.values.first as? String where dayName == day.text {
            
            let now = Int(NSDate().timeIntervalSince1970)
            
            for index in 0 ..< items.count {
                if now < items[index].values.first!.first![Session.beginTime] {
                    mainQueue({
                        if self.items.count > 0 {
                            self.tableView.scrollToRowAtIndexPath(
                                NSIndexPath(forRow: 0, inSection: index),
                                atScrollPosition: UITableViewScrollPosition.Top,
                                animated: true)
                        }
                    })
                    return
                }
            }
        }
    }
    
}
