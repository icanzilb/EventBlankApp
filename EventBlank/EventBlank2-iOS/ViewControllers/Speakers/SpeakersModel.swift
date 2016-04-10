//
//  SpeakersModel.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 2/22/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import UIKit

import RealmSwift
import RxSwift

class SpeakersModel {
    
    //loading speakers
    func speakers(searchTerm term: String = "") -> Observable<[Speaker]> {
        
        return RealmProvider.eventRealm.objects(Speaker)
            .filter("name contains[c] %@", term)
            .sorted("name")
            .asObservableArray()
    }
}
