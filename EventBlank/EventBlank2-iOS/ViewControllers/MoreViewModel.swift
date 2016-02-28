//
//  MoreViewModel.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 2/28/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources
import RxViewModel

class MoreViewModel: RxViewModel {
    
    private let bag = DisposeBag()
    
    //output
    typealias AnySection = SectionModel<String, AnyObject>
    let tableItems = BehaviorSubject<[AnySection]>(value: [])
    
    let dataSource = RxTableViewSectionedReloadDataSource<AnySection>()

    override init() {
        super.init()
        
        //bind the menu items
        let texts = RealmProvider.eventRealm.objects(Text.self).asObservableArray()
        let extra = Observable.just(["Credits", "Acknowledgements", "Pending Event Update"])
        
        Observable.combineLatest(texts, extra, resultSelector: {texts, extras in
            return [
                AnySection(model: "texts", items: texts),
                AnySection(model: "common", items: extras)
            ]
        })
        .bindTo(tableItems)
        .addDisposableTo(bag)
        
        //the data source
        dataSource.configureCell = {(tableView, indexPath, element) in
            let cell = tableView.dequeueReusableCellWithIdentifier(indexPath.section == 0 ? "MenuCell" : "ExtraMenuCell")!
            
            cell.imageView?.image = nil
            cell.textLabel?.enabled = true
            cell.accessoryType = .DisclosureIndicator
            
            if let element = element as? Text where indexPath.section == 0 {
                cell.textLabel?.text = element.title
                
            } else if let element = element as? String where indexPath.section == 1 {
                cell.textLabel?.text = element
                
                let defaults = NSUserDefaults.standardUserDefaults()
                if indexPath.row == 2 {
                    cell.textLabel?.enabled = defaults.boolForKey("isTherePendingUpdate")
                    if defaults.boolForKey("isTherePendingUpdate") {
                        cell.imageView?.image = UIImage(named: "info-red-empty")
                    } else {
                        cell.accessoryType = .None
                        cell.textLabel?.text = "👍 You got the latest schedule"
                    }
                }
            }
            return cell
        }

    }
}
