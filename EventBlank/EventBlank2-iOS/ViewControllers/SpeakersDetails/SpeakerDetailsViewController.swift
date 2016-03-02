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

protocol Storyboardable {
    static var storyboardID: String {get}
}

class SpeakerDetailsViewController: UIViewController, Storyboardable {
    
    static var storyboardID = "SpeakerDetailsViewController"
    
    private let bag = DisposeBag()

    @IBOutlet weak var tableView: UITableView!

    private var speaker: Speaker!
    private var viewModel: SpeakerDetailsViewModel!
    private var twitterProvider: TwitterController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    static func createWith(storyboard: UIStoryboard,
        speaker: Speaker,
        twitterProvider: TwitterController = TwitterController()) -> SpeakerDetailsViewController {
        
            let vc = storyboard.instantiateViewControllerWithIdentifier(storyboardID) as! SpeakerDetailsViewController
            vc.speaker = speaker
            vc.viewModel = SpeakerDetailsViewModel(speaker: speaker)
            vc.twitterProvider = twitterProvider
            return vc
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        precondition(viewModel != nil)
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