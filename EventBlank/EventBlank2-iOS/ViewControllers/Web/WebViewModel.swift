//
//  WebViewModel.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 3/4/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import RxViewModel

class WebViewModel: RxViewModel {
    
    let urlRequest = PublishSubject<NSURLRequest>()
    private let bag = DisposeBag()
    
    init(url: NSURL) {
        super.init()
        
        Observable.combineLatest(Observable.just(url), didBecomeActive, resultSelector: {url, _ in
            return NSURLRequest(URL: url)
        })
        .bindTo(urlRequest)
        .addDisposableTo(bag)
    }
}