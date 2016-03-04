//
//  SpeakersViewController.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 2/22/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class SpeakersViewController: UIViewController {
    
    // outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var btnSearch: UIBarButtonItem!
    var btnFavorites = FavoritesBarButtonItem.instance()
    
    // properties
    let viewModel = SpeakersViewModel()
    let bag = DisposeBag()
    
    // search bar
    let searchController = UISearchController(searchResultsController:  nil)
    let searchBarBtnCancel = PublishSubject<Void>()
    
    let interactor = Interactor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        setupUI()
        
        bindSearchBar()
        bindTableView()
        bindUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.active = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.active = false
    }
    
    func setupUI() {
        btnFavorites.button.tintColor = UIColor.whiteColor()
    }

    // bind
    
    func bindSearchBar() {
        //bind search bar
        searchController.searchBar.rx_text
            .bindTo(viewModel.searchTerm)
            .addDisposableTo(bag)
        
        //bind search bar
        let searchBarActive = [btnSearch.rx_tap.replaceWith(true), searchBarBtnCancel.replaceWith(false)].toObservable()
            .merge()
            .startWith(false)
            .shareReplay(1)

        //present/dismiss search bar
        searchBarActive.bindNext(toggleSearchBarVisibility).addDisposableTo(bag)
        
        //show/hide the bar
        Observable.combineLatest(searchBarActive, viewModel.rx_observe(Bool.self, "active").unwrap(), resultSelector: {a, b in
            return a && b
        })
        .bindTo(searchController.searchBar.rx_visible)
        .addDisposableTo(bag)
        
        //show/hide nav buttons
        searchBarActive
            .subscribeNext({[unowned self] hideButtons in
                self.navigationItem.leftBarButtonItem = hideButtons ? nil : self.btnSearch
                self.navigationItem.rightBarButtonItem = hideButtons ? nil : self.btnFavorites
            }).addDisposableTo(bag)
        
        
        searchBarActive.bindTo(searchController.searchBar.rx_firstResponder).addDisposableTo(bag)
        
        searchBarActive.bindNext(fadeInSearchBar).addDisposableTo(bag)
        
        searchBarActive.filterOut(true).replaceWith("").bindTo(viewModel.searchTerm).addDisposableTo(bag)
    }
    
    func bindTableView() {
        //bind table view
        viewModel.speakers
            .bindTo(tableView.rx_itemsWithDataSource(viewModel.dataSource))
            .addDisposableTo(bag)
        
        //table view delegate
        tableView.rx_itemSelected
            .subscribeNext {[unowned self] indexPath in
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                let model = self.viewModel.dataSource.itemAtIndexPath(indexPath)
                try! self.interactor.show(Segue.SpeakerDetails(speaker: model), sender: self)
            }
            .addDisposableTo(bag)
    }
    
    func bindUI() {
        //bind favorites button
        let favoritesSelected = btnFavorites.button.rx_tap
            .scan(btnFavorites.button.selected, accumulator: {selected, _ in
                return !selected
            })
            .startWith(btnFavorites.selected)
            .shareReplayLatestWhileConnected()
            .debug("favorites")
        
        favoritesSelected.bindTo(btnFavorites.rx_selected).addDisposableTo(bag)
        favoritesSelected.bindTo(viewModel.onlyFavorites).addDisposableTo(bag)
        
        //bind no items message
        viewModel.speakers
            .map {sections in sections.count == 0}
            .distinctUntilChanged()
            .startWith(false)
            .subscribeNext {[unowned self] show in
                MessageView.toggle(self.view, visible: show, text: "No speakers for that filter")
            }
            .addDisposableTo(bag)
    }
}
