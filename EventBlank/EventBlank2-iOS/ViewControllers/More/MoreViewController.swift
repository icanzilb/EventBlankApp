//
//  MoreViewController.swift
//  EventBlank
//
//  Created by Marin Todorov on 6/24/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit

import RealmSwift
import RxSwift
import RxCocoa
import Then

import VTAcknowledgementsViewController

class MoreViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var viewModel = MoreViewModel()
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //bind table
        viewModel.tableItems
            .bindTo(tableView.rx_itemsWithDataSource(viewModel.dataSource))
            .addDisposableTo(bag)

        //table view delegate
        tableView.rx_itemSelected
            .subscribeNext{[weak self] indexPath in
                guard let `self` = self else {return}
                
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                if indexPath.section == 0 {
                    
                    self.storyboard!.instantiateViewController(MDViewController).then { mdController in
                        guard let element = self.viewModel.dataSource.itemAtIndexPath(indexPath) as? Text else {
                            fatalError("couldn't send the text to the target view controller")
                        }
                        mdController.text = element
                        self.navigationController!.pushViewController(mdController, animated: true)
                    }
                } else {
                    self.showExtra(indexPath)
                }
            }
            .addDisposableTo(bag)
    }

    func showExtra(indexPath: NSIndexPath) {
        
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
                    delay(seconds: 1.5, completion: {
                        message.dismissViewControllerAnimated(true, completion: {
                            //(UIApplication.sharedApplication().delegate as! AppDelegate).updateManager!.triggerRefresh()
                        })
                    })
                }
            default: break
            }
        }
    }
}
