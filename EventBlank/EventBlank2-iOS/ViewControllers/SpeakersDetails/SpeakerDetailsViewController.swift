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
    
    let bag = DisposeBag()

    @IBOutlet weak var tableView: UITableView!

    var speaker: Speaker!
    private var viewModel: SpeakerDetailsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        precondition(speaker != nil)

        viewModel = SpeakerDetailsViewModel(speaker: speaker)
        viewModel.active = true
        
        bindUI()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.active = false
    }

    func setupUI() {
        title = speaker.name
        
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func bindUI() {
        //bind the table view
        viewModel.tableItems
            .bindTo(tableView.rx_itemsWithDataSource(viewModel.dataSource)).addDisposableTo(bag)
    }
    
}