//
//  TweetListViewController.swift
//  EventBlank
//
//  Created by Marin Todorov on 7/10/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import SQLite

let kRefreshViewHeight: CGFloat = 60.0
let kRefreshTimeout: Double = 5 * 60.0

class TweetListViewController: UIViewController, RefreshViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let twitter = TwitterController()
    var tweets = [Row]()

    var refreshView: RefreshView!
    
    var database: Database {
        return DatabaseProvider.databases[appDataFileName]!
    }
    
    var lastRefresh: NSTimeInterval = 0
    
    //MARK: - view controller
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup the UI
        setupUI()
        
        //show saved tweets
        loadTweets()
        
        //fetch new tweets
        fetchTweets()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if NSDate().timeIntervalSince1970 - lastRefresh > kRefreshTimeout {
            fetchTweets()
        }
    }
    
    func setupUI() {
        
        //setup the table
        view.backgroundColor = UIColor.whiteColor()
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        //setup refresh view
        let refreshRect = CGRect(x: 0.0, y: -kRefreshViewHeight, width: view.frame.size.width, height: kRefreshViewHeight)
        refreshView = RefreshView(frame: refreshRect, scrollView: self.tableView)
        refreshView.delegate = self
        view.insertSubview(refreshView, aboveSubview: tableView)
    }

    // MARK: - fetching data
    func refreshViewDidRefresh(refreshView: RefreshView) {
        //fetch new tweets
        fetchTweets()
    }
    
    func loadTweets() {
        fatalError("Must override with a concrete implementation")
    }
    
    func fetchTweets() {
        fatalError("Must override with a concrete implementation")
    }
        
    // MARK: scroll view methods
    func scrollViewDidScroll(scrollView: UIScrollView) {
        refreshView.scrollViewDidScroll(scrollView)
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        refreshView.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }

}
