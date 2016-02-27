//
//  MainViewModel.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 2/19/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import Foundation

import RealmSwift
import RxSwift
import RxCocoa
import RxViewModel

class MainViewModel: RxViewModel {
    
    // MARK: input
    private let fileReplaceEvent = NSNotificationCenter.defaultCenter().rx_notification(kDidReplaceEventFileNotification).replaceWith()

    // MARK: output
    var title = BehaviorSubject<String>(value: "")
    var subtitle = BehaviorSubject<String>(value: "")
    var organizer = BehaviorSubject<String>(value: "")
    var logo = BehaviorSubject<UIImage?>(value: nil)
    var mainColor = BehaviorSubject<UIColor>(value: UIColor.blackColor())
    
    // MARK: private
    let bag = DisposeBag()

    // MARK: init
    override init() {
        super.init()
        
        // refresh events
        [didBecomeActive.replaceWith(), fileReplaceEvent].toObservable()
        .merge()
        .flatMapLatest({_ in
            return RealmProvider.eventRealm.objects(EventData).asObservable()
        })
        .map({ results in results.first! })
        .debug()
        .subscribeNext({[unowned self] data in
            
            self.title.onNext(data.title)
            self.subtitle.onNext(data.subtitle)
            self.organizer.onNext("organized by \n" + data.organizer)
            self.logo.onNext(data.logo.imageValue)
            self.mainColor.onNext(data.mainColor)
            
        }).addDisposableTo(bag)
    }
}
