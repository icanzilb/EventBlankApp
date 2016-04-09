//
//  SessionsViewController.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 4/9/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import UIKit
import RxSwift

class SessionsViewController: UIViewController, ClassIdentifier {

    private let bag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView!
    
    private var viewModel: SessionsViewModel!
    
    private var day: Schedule.Day!
    
    static func createWith(storyboard: UIStoryboard, day: Schedule.Day) -> SessionsViewController {
        let vc = storyboard.instantiateViewController(SessionsViewController)
        vc.viewModel = SessionsViewModel(day: day)
        vc.title = day.text
        return vc
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.active = true
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.active = false
    }
    
    func setupUI() {
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
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
                //try! UIApplication.interactor.show(Segue.SpeakerDetails(speaker: model), sender: self)
            }
            .addDisposableTo(bag)
    }
    
}
