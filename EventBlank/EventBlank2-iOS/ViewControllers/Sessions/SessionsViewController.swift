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

class SessionsViewController: UIViewController, ClassIdentifier, UIScrollViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    private let bag = DisposeBag()
    private var viewModel: SessionsViewModel!
    private var visibilityCallback: ((Bool)->Void)!
    
    private var sectionCount = 0
    
    static func createWith(storyboard: UIStoryboard, day: Schedule.Day, visibilityCallback: (Bool)->Void) -> SessionsViewController {
        return storyboard.instantiateViewController(SessionsViewController).then {vc in
            vc.viewModel = SessionsViewModel(day: day)
            vc.title = day.text
            vc.visibilityCallback = visibilityCallback
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupUI()
        bindUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.active = true
        visibilityCallback(true)
    }
    
    func setupUI() {
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func bindUI() {
        //bind no items message
        let sessions = viewModel.sessions.shareReplay(1)
        
        sessions
            .map {sections in sections.count == 0}
            .distinctUntilChanged()
            .startWith(false)
            .subscribeNext {[unowned self] show in
                MessageView.toggle(self.view, visible: show, text: "No sessions for that day and filter")
            }
            .addDisposableTo(bag)
        
        tableView
            .rx_setDelegate(self)
            .addDisposableTo(bag)
        
        sessions
            .subscribeNext {[weak self] sessions in
                self?.sectionCount = sessions.count
            }.addDisposableTo(bag)
        
        //bind table view
        sessions
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

extension SessionsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section != sectionCount-1 ? 0 : 44
    }
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return section != sectionCount-1 ? nil : UIView(frame: CGRect(x: 0, y: 0, width: 600, height: 180))
    }
}

// MARK: - IndicatorInfoProvider
extension SessionsViewController: IndicatorInfoProvider {
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: title ?? "no title")
    }
}
