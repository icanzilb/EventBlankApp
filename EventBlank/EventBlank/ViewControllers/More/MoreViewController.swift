//
//  MoreViewController.swift
//  EventBlank
//
//  Created by Marin Todorov on 6/24/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import SQLite
import VTAcknowledgementsViewController

class MoreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var database: Database {
        return DatabaseProvider.databases[eventDataFileName]!
    }
    
    var items: [Row] = []
    var lastSelectedItem: Row?
    
    let extraItems = ["Credits", "Acknowledgements"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        items = database[TextConfig.tableName].filter({Text.content != nil && Text.content != ""}()).order(Text.title.asc).map({$0})
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let mdvc = segue.destinationViewController as? MDViewController, let item = lastSelectedItem {
            mdvc.textRow = item
        }
    }
    
    //MARK: - table view methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return items.count
        } else {
            return 2
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(indexPath.section == 0 ? "MenuCell" : "ExtraMenuCell") as! UITableViewCell
        
        if indexPath.section == 0 {
            let menuItem = items[indexPath.row]
            cell.textLabel?.text = menuItem[Text.title]
        } else {
            cell.textLabel?.text = extraItems[indexPath.row]
        }
        return cell
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 0 {
            lastSelectedItem = items[indexPath.row]
        }
        return indexPath
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                navigationController?.pushViewController(CreditViewController(), animated: true)
            } else {
                let avc = VTAcknowledgementsViewController(acknowledgementsPlistPath:
                    NSBundle.mainBundle().pathForResource("Pods-acknowledgements", ofType: "plist")!
                )
                navigationController?.pushViewController(avc, animated: true)
            }
        }
    }
    
}