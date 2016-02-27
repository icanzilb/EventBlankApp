//
//  RealmProvider.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 2/19/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import Foundation
import RealmSwift

class RealmProvider {
    
    static private var eventRealmConfig: Realm.Configuration?
    static private var appRealmConfig: Realm.Configuration?
    
    static var eventRealm = try! Realm(configuration: eventRealmConfig!)
    static var appRealm   = try! Realm(configuration: appRealmConfig!)
    
    init(eventFile: String = eventDataFileName, appFile: String = appDataFileName) {
        //event configuration
        if let eventConfig = RealmProvider.loadConfig(eventFile, path: FilePath(inLibrary: eventFile), defaultPath: FilePath(inBundle: eventFile), preferNewerSourceFile: true, readOnly: false),
            let appConfig = RealmProvider.loadConfig(appFile, path: FilePath(inLibrary: appFile), defaultPath: FilePath(inBundle: appFile), preferNewerSourceFile: false, readOnly: false)
        {
            RealmProvider.eventRealmConfig = eventConfig
            RealmProvider.appRealmConfig = appConfig
            Realm.Configuration.defaultConfiguration = eventConfig
        } else {
            fatalError("Can't load the default realm")
        }

//        if RealmProvider.eventRealm.objects(Speaker).count == 0 {
            //provide stubby data for testing
            stubbyRealm()
//        }
        
        print("auto-refresh: \(RealmProvider.eventRealm.autorefresh)")
    }
    
    private static func loadConfig(name: String, path targetPath: FilePath, defaultPath: FilePath? = nil, preferNewerSourceFile: Bool = false, readOnly: Bool = false) -> Realm.Configuration? {
        
        if let defaultPath = defaultPath {
            //copy if does not exist in target location
            do {
                print("copy from: \(defaultPath) to \(targetPath)")
                try defaultPath.copyOnceTo(targetPath)
                
                //copy if the bundle contains a newer version
                if preferNewerSourceFile {
                    try defaultPath.copyIfNewer(targetPath)
                }
                
            } catch let error as NSError {
                fatalError(error.description)
            }
        }
        
        var conf = Realm.Configuration()
        conf.readOnly = readOnly
        conf.path = targetPath.filePath
        conf.objectTypes = schemaForRealm(name)
        conf.schemaVersion = 1
        return conf
    }
    
    private static func schemaForRealm(name: String) -> [Object.Type] {
        switch name {
        case "appdata.realm":
            return [FavoriteSpeaker.self]
        default:
            return [Session.self, EventData.self, Speaker.self, Location.self, Text.self, Track.self]
        }
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
        let event = EventData()
        event.title = "Marin Conf '16"
        event.subtitle = "My own conference"
        event.beginDate = NSDate(timeIntervalSinceNow: 0)
        event.endDate = NSDate(timeIntervalSinceNow: 3 * 24 * 60 * 60)
        event.organizer = "Marin Todorov"
        event.mainColor = UIColor(hexString: "#ff3333")
        let img = UIImage(named: "marin-conf.png")!
        let imgData = UIImagePNGRepresentation(img)!
        event.logo = imgData
        
        //speakers
        let speaker1 = Speaker()
        speaker1.name = "Marin Todorov"
        speaker1.bio = "Marin Todorov is an independent iOS consultant and publisher. He’s the author of the “iOS Animations by Tutorials” book and runs the “iOS Animations by Emails” newsletter."
        speaker1.url = "http://www.underplot.com"
        speaker1.twitter = "icanzilb"
        speaker1.photo = UIImage(named: "marin_codebits_small.jpg")!
        
        let speaker2 = Speaker()
        speaker2.name = "Billy Staton"
        speaker2.bio = "Airplane Mode is an indie rock band from New York City. Dave Wiskus (vocals, guitar) and Joe Cieplinski (bass, everything else) are making a record and documenting the process in their critically-acclaimed self-titled podcast, capturing the highs and lows of forming a truly independent band in the age of social media."
        speaker2.url = "http://www.yahoo.com"
        speaker2.twitter = "billy"
        speaker2.photo = UIImage(named: "Marin-Todorov.jpg")!
        
        //tracks
        let track1 = Track()
        track1.track = "Workshops"
        track1.trackDescription = "No description available"
        
        let track2 = Track()
        track2.track = "Talks"
        track2.trackDescription = "No description available"
        
        //location
        let location1 = Location()
        location1.location = "Main Hall"
        location1.locationDescription = "The main event room"
        
        let location2 = Location()
        location2.location = "Aux Hall"
        location2.locationDescription = "The smaller event room"
        
        //sessions
        let session1 = Session()
        session1.title = "Power Up Your Animations!"
        session1.sessionDescription = "Everyone knows how to put together a simple animation for their iOS app. Most know how to scavenge StackOverflow and find the code to do something more complex they figured out they’d need. But how about if you want awesomely fantastical animations? This workshop will walk you through view and layer animations, custom transitions, and then take you on a wild ride through GitHub and 3rd party animation libraries. There won’t be any magic in this presentation – just powerful, impressive animations!"
        session1.beginTime = NSDate(timeIntervalSinceNow: 0).dateByAddingTimeInterval(-3600)
        session1.track = track1
        session1.location = location1
        session1.speakers.append(speaker1)
        
        let session2 = Session()
        session2.title = "Power Up Your Animations!"
        session2.sessionDescription = "Everyone knows how to put together a simple animation for their iOS app. Most know how to scavenge StackOverflow and find the code to do something more complex they figured out they’d need. But how about if you want awesomely fantastical animations? This workshop will walk you through view and layer animations, custom transitions, and then take you on a wild ride through GitHub and 3rd party animation libraries. There won’t be any magic in this presentation – just powerful, impressive animations!"
        session2.beginTime = NSDate(timeIntervalSinceNow: 0).dateByAddingTimeInterval(60)
        session2.track = track2
        session2.location = location2
        session2.speakers.append(speaker2)
        
        let session3 = Session()
        session3.title = "Panel: feature of Swift!"
        session3.sessionDescription = "Let's discuss Swift by the fireplace!"
        session3.beginTime = NSDate(timeIntervalSinceNow: 0).dateByAddingTimeInterval(24*60*60)
        session3.track = track2
        session3.location = location2
        session3.speakers.append(speaker2)
        
        
        try! RealmProvider.eventRealm.write {
            RealmProvider.eventRealm.deleteAll()
            
            RealmProvider.eventRealm.add(event)
            RealmProvider.eventRealm.add(speaker1)
            RealmProvider.eventRealm.add(speaker2)
            RealmProvider.eventRealm.add(track1)
            RealmProvider.eventRealm.add(track2)
            RealmProvider.eventRealm.add(location1)
            RealmProvider.eventRealm.add(location2)
            RealmProvider.eventRealm.add(session1)
            RealmProvider.eventRealm.add(session2)
        }
        
        let favorite1 = FavoriteSpeaker()
        favorite1.speakerUuid = speaker1.uuid
        
        try! RealmProvider.appRealm.write {
            RealmProvider.appRealm.deleteAll()
            RealmProvider.appRealm.add(favorite1)
        }

        delay(seconds: 3.0, completion: {
            let track1 = Track()
            track1.track = "Background Workshops"
            track1.trackDescription = "No description available"
            try! RealmProvider.eventRealm.write {
                RealmProvider.eventRealm.add(speaker1)
                print("added a background track")
            }
        })
        
        delay(seconds: 5.0, completion: {
            let speaker1 = Speaker()
            speaker1.name = "Background Speaker"
            speaker1.bio = "Background descroption"
            speaker1.url = "http://www.underplot.com"
            speaker1.twitter = "boby"
            speaker1.photo = UIImage(named: "Marin-Todorov.jpg")!
            try! RealmProvider.eventRealm.write {
                RealmProvider.eventRealm.add(speaker1)
                print("added a background speaker")
            }
        })
        
    }
}
