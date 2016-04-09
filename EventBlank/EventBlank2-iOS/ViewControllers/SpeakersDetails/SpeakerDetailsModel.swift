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
    let favorites = Variable<[String]>([])
    let speaker: Speaker
    
    let bag = DisposeBag()
    
    init(speaker: Speaker) {
        self.speaker = speaker
        
        //bind favorites
        RealmProvider.appRealm.objects(Favorites).asObservableArray().map {results -> [String] in
            return results.first!.speakerIds
        }
        .bindTo(favorites)
        .addDisposableTo(bag)
    }
    
    func updateSpeakerFavoriteTo(to: Bool) {
        //remove favorite
        if favorites.value.contains(speaker.uuid) && to == false {
            try! RealmProvider.appRealm.write {
                if let oid = RealmProvider.appRealm.objects(ObjectId).filter("id = %@", speaker.uuid).first {
                    RealmProvider.appRealm.delete(oid)
                }
            }
            return
        }
        
        //add favorite
        if !favorites.value.contains(speaker.uuid) && to == true {
            try! RealmProvider.appRealm.write {
                let oid = RealmProvider.appRealm.objects(ObjectId).filter("id = %@", speaker.uuid).first ?? ObjectId(id: speaker.uuid)
                RealmProvider.appRealm.objects(Favorites).first!.speakers.append(oid)
            }
        }
    }
}