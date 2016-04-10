//
//  SpeakersViewModel.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 2/22/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import RxDataSources
import RxViewModel

class SpeakersViewModel: RxViewModel {
    
    private let bag = DisposeBag()
    typealias SpeakerSection = SectionModel<String, Speaker>
    
    let dataSource = RxTableViewSectionedReloadDataSource<SpeakerSection>()
    private let model = SpeakersModel()
    private let favoritesModel = FavoritesModel()
    
    //
    // MARK: input
    //
    let searchTerm = Variable<String>("")
    let onlyFavorites = Variable<Bool>(false)

    private let fileReplaceEvent = NSNotificationCenter.defaultCenter().rx_notification(kDidReplaceEventFileNotification).map({_ in return})
    
    //
    // MARK: output
    //
    let speakers = PublishSubject<[SpeakerSection]>()
    
    //
    // MARK: init
    //
    override init() {
        super.init()
        
        
        //generate the speaker list, re: scott
        let search$ = searchTerm.asObservable()
            .startWith("")
            .throttle(0.1, scheduler: MainScheduler.instance)
            .flatMap {term in
                return self.model.speakers(searchTerm: term)
            }
            .distinctUntilChanged(distinctSpeakerFilter)
        
        Observable.combineLatest(search$, onlyFavorites.asObservable()) {[unowned self] results, onlyFavs -> [Speaker] in
            guard onlyFavs == true else {
                return results
            }
            
            return results.filter {speaker in
                self.favoritesModel.speakerFavorites.value.contains(speaker.uuid)
            }
        }
        .map {[unowned self] speakers in
            return speakers.breakIntoSections(self.sectionTitleWithSpeakers)
        }
        .bindTo(speakers)
        .addDisposableTo(bag)
        
        //config data source
        dataSource.configureCell = configureSpeakerCellForIndexPath
        dataSource.titleForHeaderInSection = {[weak self] dataSource, sectionIndex in
            self?.dataSource.sectionAtIndex(sectionIndex).identity
        }
    }
    
    //
    // MARK: private methods
    //
    private func distinctSpeakerFilter(list1: [Speaker], list2: [Speaker]) -> Bool {
        return list1.count == list2.count //just good enough implementation
    }
    
    func configureSpeakerCellForIndexPath(dataSource: SectionedViewDataSourceType, tableView: UITableView, index: NSIndexPath, speaker: Speaker) -> SpeakerCell {
        let cell = SpeakerCell.cellOfTable(tableView, speaker: speaker)
        
        favoritesModel.speakerFavorites.asObservable().subscribeNext {favorites in
            cell.isFavorite.onNext(favorites.contains(speaker.uuid))
        }.addDisposableTo(cell.reuseBag)
        
        return cell
    }

    func sectionTitleWithSpeakers(speaker1: Speaker, speaker2: Speaker?) -> String? {
        guard let speaker2 = speaker2 else {
            return String(speaker1.name[0])
        }
        
        return (String(speaker1.name[0]) != String(speaker2.name[0])) ? String(speaker1.name[0]) : nil
    }

}
