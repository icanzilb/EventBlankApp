//
//  SessionDetailsViewModel.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 4/9/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxViewModel
import RxDataSources
import Curry

class SessionDetailsViewModel: RxViewModel {
    
    typealias SessionSection = SectionModel<String, Session>
    
    private let bag = DisposeBag()
    private var session: Session!
    
    private var model: SessionDetailsModel!
    private let favoritesModel = FavoritesModel()
    
    //output
    let tableItems = BehaviorSubject<[SessionSection]>(value: [])
    let dataSource = RxTableViewSectionedReloadDataSource<SessionSection>()

    convenience init(session: Session) {
        self.init()
        
        self.session = session
        model = SessionDetailsModel(id: session.uuid)
        
        //bind table items
        model.sessionDetails.asObservableArray()
            .map { sessions -> [SessionSection] in
                return [SessionSection(model: "session details", items: sessions)]
            }
            .bindTo(tableItems)
            .addDisposableTo(bag)
        
        //the data source
        dataSource.configureCell = sessionDetailsCellForIndexPath
        
        dataSource.titleForHeaderInSection = {_, section in nil}
        dataSource.titleForFooterInSection = {_, section in nil}
    }
    
    //private methods
    private func sessionDetailsCellForIndexPath(dataSource: SectionedViewDataSourceType, tableView: UITableView, index: NSIndexPath, session: Session) -> SessionDetailsCell {
        let cell = SessionDetailsCell.cellOfTable(tableView, session: session, event: EventData.defaultEvent)
        
        //is favorite
        favoritesModel.sessionFavorites.asObservable()
            .map {favorites in favorites.contains(session.speakers.first!.uuid)}
            .bindTo(cell.isFavorite)
            .addDisposableTo(self.bag)
        
        //toggle favorite
        cell.isFavorite
            .distinctUntilChanged()
            .bindNext(curry(favoritesModel.updateSessionFavoriteTo)(session))
            .addDisposableTo(self.bag)
        
        return cell
    }
}