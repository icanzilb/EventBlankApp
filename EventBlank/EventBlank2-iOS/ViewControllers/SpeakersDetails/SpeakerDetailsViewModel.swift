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
        
        // twitter
        let tweets = Variable<[Tweet]>([])

        if let targetTwitterUsername = speaker.twitter {
            twitterProvider.currentAccount()
            .flatMapLatest {account in
                return twitterProvider.timelineForUsername(account, username: targetTwitterUsername)
            }
            .bindTo(tweets)
            .addDisposableTo(bag)
        }
        
        //bind table items
        Observable.combineLatest(Observable.just(speaker), tweets.asObservable(), resultSelector: { speaker, tweets in
            return Array<AnySection>([
                AnySection(model: "details", items: [speaker]),
                AnySection(model: "tweets", items: tweets)
            ])
        })
        .bindTo(tableItems)
        .addDisposableTo(bag)

        //the data source
        dataSource.configureCell = {[unowned self] (tv, indexPath, item) in
            switch indexPath.section {
            case 0: return self.speakerDetailsCell(tv, speaker: speaker, twitterProvider: twitterProvider)
            case 1: return TweetCell.cellOfTable(tv, tweet: item as! Tweet)
            default: return UITableViewCell()
            }
        }
        
        //section headers
        dataSource.titleForHeaderInSection = {section in
            switch section {
            case 0: return "Speaker Details"
            case 1: return "Latest Tweets"
            default: return ""
            }
        }
    }
    
    //private methods
    private func speakerDetailsCell(tv: UITableView, speaker: Speaker, twitterProvider: TwitterProvider) -> SpeakerDetailsCell {
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

        //is following
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