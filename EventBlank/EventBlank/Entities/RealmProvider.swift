//
//  Database.swift
//  EventBlank
//
//  Created by Marin Todorov on 3/12/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import Foundation
import RealmSwift

class RealmProvider {

    static private var eventRealmConfig: Realm.Configuration?
    static private var appRealmConfig: Realm.Configuration?

    static var eventRealm: Realm {
        print("event realm!")
        return try! Realm(configuration: eventRealmConfig!)
    }

    static var appRealm: Realm {
        return try! Realm(configuration: appRealmConfig!)
    }
    
    init(eventFile: String = eventDataFileName, appFile: String = appDataFileName) {
        //event configuration
        if let eventConfig = loadConfig(eventFile, path: FilePath(inLibrary: eventFile), defaultPath: FilePath(inBundle: eventFile), preferNewerSourceFile: true),
            let appConfig = loadConfig(appFile, path: FilePath(inLibrary: appFile), defaultPath: FilePath(inBundle: appFile))
        {
            RealmProvider.eventRealmConfig = eventConfig
            RealmProvider.appRealmConfig = appConfig
            Realm.Configuration.defaultConfiguration = eventConfig
        } else {
            fatalError("Can't load the default realm")
        }
        stubbyRealm()
    }
    
    func loadConfig(name: String, path targetPath: FilePath, defaultPath: FilePath? = nil, preferNewerSourceFile: Bool = false) -> Realm.Configuration? {
        
        if let defaultPath = defaultPath {
            
            //copy if does not exist in target location
            do {
                try defaultPath.copyOnceTo(targetPath)

                //copy if the bundle contains a newer version
                if preferNewerSourceFile {
                    try defaultPath.copyIfNewer(targetPath)
                }
            } catch let error as NSError {
                fatalError(error.description)
            }
        }
        
        let config = Realm.Configuration(path: targetPath.filePath, readOnly: false)
        loadDatabaseFile(name)
        return config
        
    }
    
    private func loadDatabaseFile(name: String) {
        //TODO: connect a database?
    }
    
    func didChangeSourceFile(name: String, success: Bool) {
        print("Database Provider: reload database: \(name)")
        loadDatabaseFile(name)
    }
    
    func stubbyRealm() {
        //event
        print("stubby realm")

        let event = EventData()
        event.title = "Marin Conf '16"
        event.subtitle = "My own conference"
        event.beginDate = NSDate(timeIntervalSinceNow: 0)
        event.endDate = NSDate(timeIntervalSinceNow: 3 * 24 * 60 * 60)
        event.organizer = "Marin Todorov"
        event.mainColor = "#ff3333"
        let img = UIImage(named: "pragma15-logo.png")!
        let imgData = UIImagePNGRepresentation(img)!
        event.logo = imgData
        
        //speakers
        let speaker1 = Speaker()
        speaker1.name = "Ashley Nelson-Hornstein"
        speaker1.bio = "Ashley Nelson-Hornstein is an iOS developer at Dropbox. She fell in love with the iOS platform at Apple, and later developed a passion for crafting intuitive user interfaces as a lead at a news startup named Circa. When not driving new features or advocating for accessibility at Dropbox, Ashley enjoys reading, weightlifting, and trying really hard not to let her blog go stale."
        speaker1.url = "http://www.underplot.com"
        speaker1.twitter = "ashley"
        speaker1.photo = UIImagePNGRepresentation(UIImage(named: "ashley.jpg")!)!
        
        let speaker2 = Speaker()
        speaker2.name = "Bibi Nonaka"
        speaker2.bio = "Airplane Mode is an indie rock band from New York City. Dave Wiskus (vocals, guitar) and Joe Cieplinski (bass, everything else) are making a record and documenting the process in their critically-acclaimed self-titled podcast, capturing the highs and lows of forming a truly independent band in the age of social media."
        speaker2.url = "http://www.yahoo.com"
        speaker2.twitter = "ayaka"
        speaker2.photo = UIImagePNGRepresentation(UIImage(named: "ayaka.jpg")!)!
        
        
        
        try! RealmProvider.eventRealm.write {
            RealmProvider.eventRealm.deleteAll()
            
            RealmProvider.eventRealm.add(event)
            RealmProvider.eventRealm.add(speaker1)
            RealmProvider.eventRealm.add(speaker2)
            
        }
        
    }
}