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
    
    private let bag = DisposeBag()
    private let model: SpeakerDetailsModel
    
    //output
    typealias AnySection = SectionModel<String, AnyObject>
    let tableItems = BehaviorSubject<[AnySection]>(value: [])
    
    init(speaker: Speaker) {
        self.model = SpeakerDetailsModel(speaker: speaker)
        
        super.init()
        
        tableItems.onNext([
            AnySection(model: "details", items: [speaker])
            ])
        
    }
    
}