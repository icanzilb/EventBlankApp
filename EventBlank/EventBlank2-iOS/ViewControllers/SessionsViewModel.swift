//
//  SessionsViewModel.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 4/9/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxViewModel
import RxCocoa
import RxDataSources

class SessionsViewModel: RxViewModel {
    
    typealias SessionSection = SectionModel<String, Session>
    
    let dataSource = RxTableViewSectionedReloadDataSource<SessionSection>()
    
    //
    // MARK: output
    //
    let sessions = PublishSubject<[SessionSection]>()
    private let bag = DisposeBag()
    
    convenience init(day: Schedule.Day) {
        self.init()
        
        //generate the speaker list
        let realm = try! Realm()
        
        let sessionObjects = realm.objects(Session).filter("beginTime >= %@ AND beginTime <= %@", day.startTime, day.endTime).sorted("beginTime")

        sessionObjects.asObservableArray()
            .distinctUntilChanged(distinctCountFilter)
            .map { results in
                return results.breakIntoSections(self.sectionTitleWithSessions)
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
        let cell = SessionCell.cellOfTable(tableView, session: session)
//        model.favorites.subscribeNext {favorites in
//            cell.isFavorite.onNext(favorites.contains(speaker.uuid))
//            }.addDisposableTo(bag)
        return cell
    }

    func sectionTitleWithSessions(session1: Session, session2: Session?) -> String? {
        guard let session2 = session2 else {
            return shortStyleDateFormatter.stringFromDate(session1.beginTime!)
        }
        
        return shortStyleDateFormatter.stringFromDate(session1.beginTime!) != shortStyleDateFormatter.stringFromDate(session2.beginTime!) ? shortStyleDateFormatter.stringFromDate(session1.beginTime!) : nil
    }

}