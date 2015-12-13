//
//  MoreViewController.swift
//  EventBlank
//
//  Created by Marin Todorov on 6/24/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import RealmSwift
import VTAcknowledgementsViewController

class MoreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var database: Database {
        return DatabaseProvider.databases[eventDataFileName]!
    }
    
    var items: [Row] = []
    var lastSelectedItem: Row?
    
    let extraItems = ["Credits", "Acknowledgements", "Pending Event Update"]
    
    func loadItems() {
        items = database[TextConfig.tableName].filter({Text.content != nil && Text.content != ""}()).order(Text.title.asc).map({$0})
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundQueue(loadItems, completion: {
            self.tableView.reloadData()
        })
        
        //notifications
        observeNotification(kDidReplaceEventFileNotification, selector: "didChangeEventFile")
        observeNotification(kPendingUpdateChangedNotification, selector: "didChangePendingUpdate")
    }

    deinit {
        //notifications
        observeNotification(kDidReplaceEventFileNotification, selector: nil)
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
            return extraItems.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(indexPath.section == 0 ? "MenuCell" : "ExtraMenuCell") as! UITableViewCell
        
        cell.imageView?.image = nil
        cell.textLabel?.enabled = true
        cell.accessoryType = .DisclosureIndicator
        
        if indexPath.section == 0 {
            let menuItem = items[indexPath.row]
            cell.textLabel?.text = menuItem[Text.title]
        } else {
            cell.textLabel?.text = extraItems[indexPath.row]

            let defaults = NSUserDefaults.standardUserDefaults()
            if indexPath.row == 2 {
                cell.textLabel?.enabled = defaults.boolForKey("isTherePendingUpdate")
                if defaults.boolForKey("isTherePendingUpdate") {
                    cell.imageView?.image = UIImage(named: "info-red-empty")
                } else {
                    cell.accessoryType = .None
                }
            }
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
            switch indexPath.row {
            case 0:
                navigationController?.pushViewController(CreditViewController(), animated: true)
                
            case 1:
                let avc = VTAcknowledgementsViewController(acknowledgementsPlistPath:
                    NSBundle.mainBundle().pathForResource("Pods-acknowledgements", ofType: "plist")!
                )
                navigationController?.pushViewController(avc!, animated: true)
                
            case 2:
                let defaults = NSUserDefaults.standardUserDefaults()
                if defaults.boolForKey("isTherePendingUpdate") {
                    let message = alert("Sending update request - it might take a moment to complete...", buttons: [], completion: nil)
                    delay(seconds: 1.5, {
                        message.dismissViewControllerAnimated(true, completion: {
                            (UIApplication.sharedApplication().delegate as! AppDelegate).updateManager!.triggerRefresh()
                        })
                    })
                }
            default: break
            }
        }
    }
    
    //notifications
    func didChangeEventFile() {
        mainQueue({
            self.navigationController?.popToRootViewControllerAnimated(true)
            self.tableView.reloadData()
        })
    }
    
    func didChangePendingUpdate() {
        mainQueue { self.tableView.reloadData() }
    }
    
}