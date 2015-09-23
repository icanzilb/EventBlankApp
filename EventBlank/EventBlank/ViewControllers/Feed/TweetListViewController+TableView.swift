//
//  TweetListViewController+TableView.swift
//  EventBlank
//
//  Created by Marin Todorov on 9/22/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit

//MARK: table view methods
extension TweetListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tweet = tweets[indexPath.row]
        if let urlString = tweet[News.url], let url = NSURL(string: urlString) {
            let webVC = storyboard?.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
            webVC.initialURL = url
            navigationController!.pushViewController(webVC, animated: true)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 100.0
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        fatalError()
    }
}
