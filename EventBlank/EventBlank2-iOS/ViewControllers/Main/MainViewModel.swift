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
    let title = BehaviorSubject<String>(value: "")
    let subtitle = BehaviorSubject<String>(value: "")
    let organizer = BehaviorSubject<String>(value: "")
    let logo = BehaviorSubject<UIImage?>(value: nil)
    let mainColor = BehaviorSubject<UIColor>(value: UIColor.blackColor())
    
    let nextEvent = BehaviorSubject<Schedule.NextEventResult?>(value: nil)
    
    // MARK: private
    private let bag = DisposeBag()

    private let schedule = Schedule()
    var timer: Observable<NSInteger>!

    // MARK: init
    override init() {
        super.init()
        
        // refresh events
        fileReplaceEvent
            .startWith(())
            .replaceWith(EventData.defaultEvent)
            .observeOn(MainScheduler.instance)
            .subscribeNext {[unowned self] data in
                self.title.onNext(data.title)
                self.subtitle.onNext(data.subtitle)
                self.organizer.onNext("organized by \n" + data.organizer)
                self.logo.onNext(data.logo)
                self.mainColor.onNext(data.mainColor)
            }.addDisposableTo(bag)
        
        // show the next event
        timer = Observable<NSInteger>.interval(1, scheduler: MainScheduler.instance)
        timer
            .map {[unowned self]_ in self.schedule.nextEvent()}
            .bindTo(nextEvent)
            .addDisposableTo(bag)
    }
}
