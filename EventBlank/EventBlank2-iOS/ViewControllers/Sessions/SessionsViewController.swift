//
//  SessionsViewController.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 4/9/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

import XLPagerTabStrip

class SessionsViewController: UIViewController, ClassIdentifier {

    @IBOutlet weak var tableView: UITableView!
    
    private let bag = DisposeBag()
    private var viewModel: SessionsViewModel!
    private var day: Schedule.Day!
    private var visibilityCallback: ((Bool)->Void)!
    
    static func createWith(storyboard: UIStoryboard, day: Schedule.Day, visibilityCallback: (Bool)->Void) -> SessionsViewController {
        let vc = storyboard.instantiateViewController(SessionsViewController)
        vc.viewModel = SessionsViewModel(day: day)
        vc.title = day.text
        vc.day = day
        vc.visibilityCallback = visibilityCallback
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupUI()
        
        bindUI()
        bindTableView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.active = true
        visibilityCallback(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.active = false
    }
    
    func setupUI() {
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func bindUI() {
        //bind no items message
        viewModel.sessions
            .map {sections in sections.count == 0}
            .distinctUntilChanged()
            .startWith(false)
            .subscribeNext {[unowned self] show in
                MessageView.toggle(self.view, visible: show, text: "No sessions for that day and filter")
            }
            .addDisposableTo(bag)
    }
    
    func bindTableView() {
        //bind table view
        viewModel.sessions
            .bindTo(tableView.rx_itemsWithDataSource(viewModel.dataSource))
            .addDisposableTo(bag)
        
        //table view delegate
        tableView.rx_itemSelected
            .subscribeNext {[unowned self] indexPath in
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                let model = self.viewModel.dataSource.itemAtIndexPath(indexPath)
                self.visibilityCallback(false)
                try! UIApplication.interactor.show(Segue.SessionDetails(session: model), sender: self)
            }
            .addDisposableTo(bag)
    }
    
}

// MARK: - IndicatorInfoProvider
extension SessionsViewController: IndicatorInfoProvider {
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: title ?? "no title")
    }
}
