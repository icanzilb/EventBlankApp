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
    
    let loadUrl = PublishSubject<NSURL>()

    private let url: Observable<NSURL>
    
    init(url: NSURL) {
        self.url = BehaviorSubject<NSURL>(value: url)
        
    }
    
}