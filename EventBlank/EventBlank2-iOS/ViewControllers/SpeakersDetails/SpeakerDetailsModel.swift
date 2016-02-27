//
//  SpeakerDetailsModel.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 2/25/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import UIKit
import RealmSwift

import RxSwift

class SpeakerDetailsModel: NSObject {

    //favorites
    let favorites = RealmProvider.appRealm.objects(FavoriteSpeaker).asObservableArray()
        .map { $0.map {speaker in speaker.speakerUuid} }

    let speaker: Speaker
    
    init(speaker: Speaker) {
        self.speaker = speaker
    }
    
    func updateSpeakerFavoriteTo(to: Bool) {
        let fav = RealmProvider.appRealm.objectForPrimaryKey(FavoriteSpeaker.self, key: speaker.uuid)
        
        if let fav = fav where to == false {
            try! RealmProvider.appRealm.write {
                RealmProvider.appRealm.delete(fav)
            }
        }
        if fav == nil && to == true {
            try! RealmProvider.appRealm.write {
                let newFav = FavoriteSpeaker()
                newFav.speakerUuid = speaker.uuid
                RealmProvider.appRealm.add(newFav)
            }
        }
    }
}