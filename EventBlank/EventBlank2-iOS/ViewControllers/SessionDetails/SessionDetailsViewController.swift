//
//  SessionDetailsViewController.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 4/9/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

class SessionDetailsViewController: UIViewController, ClassIdentifier {
    
    private let bag = DisposeBag()
    private var viewModel: SessionDetailsViewModel!
    private var session: Session!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindUI()
    }
    
    static func createWith(storyboard: UIStoryboard,
                           session: Session) -> SessionDetailsViewController {
        
        return storyboard.instantiateViewController(SessionDetailsViewController).then {vc in
            vc.session = session
            vc.viewModel = SessionDetailsViewModel(session: session)
        }
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
    
    func bindUI() {
        //bind the table view
        viewModel.tableItems
            .bindTo(tableView.rx_itemsWithDataSource(viewModel.dataSource))
            .addDisposableTo(bag)
    }
}