//
//  SessionsViewModel.swift
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

class SessionsViewModel: RxViewModel {
    
    typealias SessionSection = SectionModel<String, Session>
    
    let dataSource = RxTableViewSectionedReloadDataSource<SessionSection>()
    private let model = SessionsModel()
    private let bag = DisposeBag()
    private var event: EventData!
    
    //
    // MARK: input
    //
    let onlyFavorites = Variable<Bool>(false)

    //
    // MARK: output
    //
    let sessions = PublishSubject<[SessionSection]>()
    
    convenience init(day: Schedule.Day) {
        self.init()

        event = EventModel().eventData()
        
        //bind sessions
        let sessionsList = onlyFavorites.asObservable()
            .flatMapLatest {[unowned self] favs in
                return self.model.sessions(day, onlyFavorites: favs).asObservableArray()
            }
            .distinctUntilChanged(distinctCountFilter)
            .map { results in
                return results.breakIntoSections(self.sectionTitleWithSessions)
            }
        
        //generate reload events
        didBecomeActive.replaceWith().take(1)
            .flatMapLatest {
                return sessionsList
            }
            .bindTo(sessions)
            .addDisposableTo(bag)
        
        //config data source
        dataSource.configureCell = configureSessionCellForIndexPath
        dataSource.titleForHeaderInSection = {[weak self] dataSource, sectionIndex in
            self?.dataSource.sectionAtIndex(sectionIndex).identity
        }
    }
    
    //
    // MARK: private methods
    //
    
    private func distinctCountFilter(list1: [Session], list2: [Session]) -> Bool {
        return list1.count == list2.count //just good enough implementation
    }

    func configureSessionCellForIndexPath(dataSource: SectionedViewDataSourceType, tableView: UITableView, index: NSIndexPath, session: Session) -> SessionCell {
        let cell = SessionCell.cellOfTable(tableView, session: session, event: event)
        
        model.sessionFavorites.asObservable().subscribeNext {favorites in
            cell.isFavorite.onNext(favorites.contains(session.uuid))
        }.addDisposableTo(bag)
        model.speakerFavorites.asObservable().subscribeNext {favorites in
            cell.isFavoriteSpeaker.onNext(favorites.contains(session.speakers.first!.uuid))
        }.addDisposableTo(bag)
        
        //toggle favorite
        cell.isFavorite
            .bindNext(curry(model.updateSessionFavoriteTo)(session))
            .addDisposableTo(bag)
        
        return cell
    }

    func sectionTitleWithSessions(session1: Session, session2: Session?) -> String? {
        guard let session2 = session2 else {
            return shortStyleDateFormatter.stringFromDate(session1.beginTime!)
        }
        
        return shortStyleDateFormatter.stringFromDate(session1.beginTime!) != shortStyleDateFormatter.stringFromDate(session2.beginTime!) ? shortStyleDateFormatter.stringFromDate(session1.beginTime!) : nil
    }

}