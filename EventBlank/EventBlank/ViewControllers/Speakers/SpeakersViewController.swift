//
//  SpeakersViewController.swift
//  EventBlank
//
//  Created by Marin Todorov on 12/15/15.
//  Copyright © 2015 Underplot ltd. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

import RxSwift
import RxCocoa

typealias SpeakerSection = SectionModel<String, Speaker>

class SpeakersViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var btnFavorites = UIButton()
    let searchController = UISearchController(searchResultsController:  nil)
    
    var speakers = SpeakersModel()
    var items: Observable<[SpeakerSection]> = just([])
    
    var disposeBag = DisposeBag()
    let dataSource = RxTableViewSectionedReloadDataSource<SpeakerSection>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load speakers
        speakers.load(searchTerm: searchController.searchBar.text!,
            showOnlyFavorites: btnFavorites.selected)
        
        //config the table
        dataSource.cellFactory = {tv, indexPath, element in
            return self.configureSpeakerCellForIndexPath(element)
        }
        
        //bind items
        items = just(speakers.items)
        items
            .bindTo(tableView.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(disposeBag)
        
        //config table delegate
        tableView
            .rx_itemSelected
            .map { indexPath in
                return (indexPath, self.dataSource.itemAtIndexPath(indexPath))
            }
            .subscribeNext { indexPath, model in
                DefaultWireframe.presentAlert("Tapped `\(model)` @ \(indexPath)")
            }
            .addDisposableTo(disposeBag)
        
        tableView
            .rx_setDelegate(self)
            .addDisposableTo(disposeBag)
    }
    
    func configureSpeakerCellForIndexPath(speaker: Speaker) -> SpeakerCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("SpeakerCell") as! SpeakerCell
        cell.populateFromSpeaker(speaker)
        return cell
    }
}