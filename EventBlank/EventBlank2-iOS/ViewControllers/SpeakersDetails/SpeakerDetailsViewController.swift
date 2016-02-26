//
//  SpeakerDetailsViewController.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 2/23/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import RxDataSources

class SpeakerDetailsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    var speaker: Speaker!
    
    let dataSource = RxTableViewSectionedReloadDataSource<SpeakerDetailsViewModel.AnySection>()
    var viewModel: SpeakerDetailsViewModel!
    
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        precondition(speaker != nil)

        viewModel = SpeakerDetailsViewModel(speaker: speaker)
        bindUI()

        viewModel.active = true
    }

    func setupUI() {
        title = speaker.name
        
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func bindUI() {
        //set the cell factory
        dataSource.configureCell = {[unowned self] (tv, indexPath, element) in
            switch indexPath.section {
            case 0: return (tv.dequeueReusableCellWithIdentifier("SpeakerDetailsCell") as! SpeakerDetailsCell).populateFromSpeaker(self.speaker)
            default: return UITableViewCell()
            }
        }
        
        viewModel.tableItems
            .debug("table items")
            .bindTo(tableView.rx_itemsWithDataSource(dataSource)).addDisposableTo(bag)
    }
}