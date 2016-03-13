//
//  SpeakerDetailsViewModel.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 2/25/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import RxDataSources
import RxViewModel

class SpeakerDetailsViewModel: RxViewModel {

    typealias AnySection = SectionModel<String, AnyObject>
    
    private let bag = DisposeBag()
    private let model: SpeakerDetailsModel
    
    //output
    let tableItems = BehaviorSubject<[AnySection]>(value: [])
    let dataSource = RxTableViewSectionedReloadDataSource<AnySection>()

    //init
    init(speaker: Speaker, twitterProvider: TwitterProvider) {
        self.model = SpeakerDetailsModel(speaker: speaker)
        
        super.init()
        
        //table items
        tableItems.onNext([
            AnySection(model: "details", items: [speaker])
            ])
        
        //the data source
        dataSource.configureCell = {[unowned self] (tv, indexPath, _) in
            switch indexPath.section {
            case 0: return self.setupSpeakerDetailsCell(tv, speaker: speaker, twitterProvider: twitterProvider)
            default: return UITableViewCell()
            }
        }
        
        //section headers
        dataSource.titleForHeaderInSection = {section in
            return "Speaker Details"
        }
    }
    
    //private methods
    private func setupSpeakerDetailsCell(tv: UITableView, speaker: Speaker, twitterProvider: TwitterProvider) -> SpeakerDetailsCell {
        let cell = SpeakerDetailsCell.cellOfTable(tv, speaker: speaker)
        
        //is favorite
        self.model.favorites
            .map {favorites in favorites.contains(speaker.uuid)}
            .bindTo(cell.isFavorite)
            .addDisposableTo(self.bag)
        
        //toggle favorite
        cell.isFavorite
            .bindNext(self.model.updateSpeakerFavoriteTo)
            .addDisposableTo(self.bag)
        
        //wire twitter
        if let targetTwitterUsername = speaker.twitter {
            
            twitterProvider.currentAccount()
                .flatMapLatest {account in
                    return twitterProvider.isFollowingUser(account, username: targetTwitterUsername)
                }
                .bindTo(cell.isFollowing)
                .addDisposableTo(bag)
        }
        
        return cell
    }
}