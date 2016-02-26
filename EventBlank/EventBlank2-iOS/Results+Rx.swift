//
// Results+Rx.swift
//
// Make Realm auto-updating Results observable. Works with Realm 0.98 and later, RxSwift 2.1.0 and later.
//
// Created by Florent Pillet on 12/02/16.
// Copyright (c) 2016 Florent Pillet. All rights reserved.
//

import Foundation

import RealmSwift
import RxSwift

extension Results {
    
    /// turn a Realm Results into an Observable sequence that sends the Results object itself once at query, then
    /// again every time a change occurs in the Results. Caller just subscribes to the observable to get
    /// updates. Note that Realm may send updates even when there is no actual change to the data
    /// (Realm docs mention they will fine tune this later)
    func asObservable() -> Observable<Results<Element>> {
        return Observable.create { observer in
            var token: NotificationToken? = nil
            token = self.addNotificationBlock { (results, error) in
                guard error == nil else {
                    observer.onError(error!)
                    return
                }
                observer.onNext(results!)
            }
            return AnonymousDisposable {
                token?.stop()
            }
        }
    }
    
    /// turn a Realm Results into an Observable sequence that sends the Results object itself once at query, then
    /// again every time a change occurs in the Results. Caller just subscribes to the observable to get
    /// updates. Note that Realm may send updates even when there is no actual change to the data
    /// (Realm docs mention they will fine tune this later)
    func asObservableArray() -> Observable<[Element]> {
        return Observable.create { observer in
            var token: NotificationToken? = nil
            token = self.addNotificationBlock { (results, error) in
                guard error == nil else {
                    observer.onError(error!)
                    return
                }
                observer.onNext(Array(self))
            }
            return AnonymousDisposable {
                token?.stop()
            }
        }
    }
    
}