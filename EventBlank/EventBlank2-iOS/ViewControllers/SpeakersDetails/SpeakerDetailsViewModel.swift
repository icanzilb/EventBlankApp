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
import Curry

class SpeakerDetailsViewModel: RxViewModel {

    typealias AnySection = SectionModel<String, AnyObject>
    
    private let bag = DisposeBag()
    private let model: SpeakerDetailsModel
    private let favoritesModel = FavoritesModel()
    
    //output
    let tableItems = BehaviorSubject<[AnySection]>(value: [])
    let dataSource = RxTableViewSectionedReloadDataSource<AnySection>()

    //init
    init(speaker: Speaker, twitterProvider: TwitterProvider) {
        model = SpeakerDetailsModel(speaker: speaker)
        
        super.init()
        
        // twitter
        let tweets = Variable<[Tweet]?>(nil)

        if let targetTwitterUsername = speaker.twitter {
            twitterProvider.currentAccount()
            .unwrap()
            .flatMapLatest {account in
                return twitterProvider.timelineForUsername(account, username: targetTwitterUsername)
            }
            .bindTo(tweets)
            .addDisposableTo(bag)
        }
        
        //bind table items
        Observable.combineLatest(Observable.just(speaker), tweets.asObservable(), resultSelector: { speaker, tweets in
            if let tweets = tweets {
                return [AnySection(model: "details", items: [speaker]),
                        AnySection(model: "tweets", items: tweets)]
            } else {
                return [AnySection(model: "details", items: [speaker])]
            }
        })
        .bindTo(tableItems)
        .addDisposableTo(bag)

        //the data source
        dataSource.configureCell = {[weak self] (_, tv, indexPath, item) in
            guard let `self` = self else {return UITableViewCell()}
            
            switch indexPath.section {
            case 0: return self.speakerDetailsCell(tv, speaker: speaker, twitterProvider: twitterProvider)
            case 1: return TweetCell.cellOfTable(tv, tweet: item as! Tweet)
            default: return UITableViewCell()
            }
        }
        
        //section headers
        dataSource.titleForHeaderInSection = {_, section in
            switch section {
            case 0: return "Speaker Details"
            case 1: return "Latest Tweets"
            default: return ""
            }
        }
        
        dataSource.titleForFooterInSection = {[weak self] _, section in
            guard let `self` = self else {return nil}
            
            switch section {
            case 1:
                if let items = try? self.tableItems.value() where items.count < 2 {
                    return "Log in to your Twitter account in your iPhone's Settings app to be able to see tweets right in this app"
                } else {
                    fallthrough
                }
            default: return nil
            }
        }
    }
    
    //private methods
    private func speakerDetailsCell(tv: UITableView, speaker: Speaker, twitterProvider: TwitterProvider) -> SpeakerDetailsCell {
        let cell = SpeakerDetailsCell.cellOfTable(tv, speaker: speaker)
        
        //is favorite
        favoritesModel.speakerFavorites.asObservable()
            .map {favorites in favorites.contains(speaker.uuid)}
            .bindTo(cell.isFavorite)
            .addDisposableTo(self.bag)
        
        //toggle favorite
        cell.isFavorite
            .distinctUntilChanged()
            .bindNext(curry(favoritesModel.updateSpeakerFavoriteTo)(speaker))
            .addDisposableTo(self.bag)

        //is following
        if let targetTwitterUsername = speaker.twitter {
            twitterProvider.currentAccount()
                .flatMapLatest {account -> Observable<FollowingOnTwitter> in
                    if let account = account {
                        return twitterProvider.isFollowingUser(account, username: targetTwitterUsername)
                    } else {
                        return Observable.just(.NA)
                    }
                }
                .bindTo(cell.isFollowing)
                .addDisposableTo(bag)
        }

        return cell
    }
}