//
//  SpeakerConfig.swift
//  EventBlankProducer
//
//  Created by Marin Todorov on 3/14/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import Foundation
import RealmSwift

let SpeakerConfig = EntityConfig(
    tableName: "speakers",
    entityName: "Speaker",
    idColumnName: "id_speaker",
    titleColumnName: "speaker",
    listImageName: "EventBlankProducer.SpeakersSplitViewController"
)

struct Speaker {

    //
    // columns
    //
    static let idColumn = Expression<Int>(SpeakerConfig.idColumnName)
    static let name = Expression<String>(SpeakerConfig.titleColumnName)
    static let bio = Expression<String?>("bio")
    static let url = Expression<String?>("speaker_url")
    static let twitter = Expression<String?>("speaker_twitter")
    static let photo = Expression<Blob?>("photo")
    
}
