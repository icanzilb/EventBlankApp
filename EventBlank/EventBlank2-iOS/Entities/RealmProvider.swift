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
    
    static var eventRealm: Realm!
    static var appRealm: Realm!
    
    init(eventFile: String = eventDataFileName, appFile: String = appDataFileName) {

        let eventRealmConfig = RealmProvider.loadConfig(eventFile, path: FilePath(inLibrary: eventFile), defaultPath: FilePath(inBundle: eventFile), preferNewerSourceFile: true, readOnly: false)
        let appRealmConfig = RealmProvider.loadConfig(appFile, path: FilePath(inLibrary: appFile), defaultPath: FilePath(inBundle: appFile), preferNewerSourceFile: false, readOnly: false)
        
        guard let eventConfig = eventRealmConfig, let appConfig = appRealmConfig else {
            fatalError("Can't load the default realm")
        }
        
        Realm.Configuration.defaultConfiguration = eventConfig
        
        RealmProvider.eventRealm = try! Realm(configuration: eventConfig)
        RealmProvider.appRealm = try! Realm(configuration: appConfig)
        
        stubbyRealmData()
    }
    
    private static func loadConfig(name: String, path targetPath: FilePath, defaultPath: FilePath? = nil, preferNewerSourceFile: Bool = false, readOnly: Bool = false) -> Realm.Configuration? {
        
        if let defaultPath = defaultPath {
            do {
                try defaultPath.copyOnceTo(targetPath)
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
            return [Favorites.self, ObjectId.self]
        default:
            return [Session.self, EventData.self, Speaker.self, Location.self, Text.self, Track.self]
        }
    }
}

//MARK: - Stubby data
extension RealmProvider {
    func stubbyRealmData() {
        //event
        let event = EventData()
        event.title = "Marin Conf '16"
        event.subtitle = "My own conference"
        event.organizer = "Marin Todorov"
        event.mainColor = UIColor(hexString: "#ff3333")
        event.logo = UIImage(named: "marin-conf.png")
        
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
        speaker2.url = "https://www.google.com"
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
        
        let text1 = Text()
        text1.title = "Code of Conduct"
        text1.content = "All attendees, speakers, sponsors and volunteers at our conference are required to agree with the following inclusivity policy. Organizers will enforce this policy throughout the event. We are expecting cooperation from all participants to help ensuring a safe environment for everybody.\n\n## Short version\n\nPragma Conference is dedicated to providing a harassment-free conference experience for everyone, regardless of gender, sexual orientation, disability, physical appearance, body size, race, or religion. We do not tolerate harassment of conference participants in any form. Sexual language and imagery is not appropriate for any conference venue, including talks, workshops, parties, Twitter and other online media. Conference participants violating these rules may be sanctioned or expelled from the conference without a refund at the discretion of the conference organizers.\n\n## Long version\n\nHarassment includes offensive verbal comments related to gender, sexual orientation, disability, physical appearance, body size, race, religion, sexual images in public spaces, deliberate intimidation, stalking, following, harassing photography or recording, sustained disruption of talks or other events, inappropriate physical contact, and unwelcome sexual attention. \n\nParticipants asked to stop any harassing behavior are expected to comply immediately. \n\nSponsors are also subject to the anti-harassment policy. In particular, sponsors should not use sexualized images, activities, or other material. Booth staff (including volunteers) should not use sexualized clothing/uniforms/costumes, or otherwise create a sexualized environment. \n\nIf a participant engages in harassing behavior, the conference organizers may take any action they deem appropriate, including warning the offender or expulsion from the conference with no refund. \n\nIf you are being harassed, notice that someone else is being harassed, or have any other concerns, please contact a member of conference staff immediately. Conference staff can be identified by a black conference shirt with a orange or black Pragma Conference logo. \n\nConference staff will be happy to help participants contact hotel/venue security or local law enforcement, provide escorts, or otherwise assist those experiencing harassment to feel safe for the duration of the conference. We value your attendance. \n\nWe expect participants to follow these rules at conference and workshop venues and conference-related social events."
        text1.required = true
        
        let text2 = Text()
        text2.title = "About"
        text2.content = "## The iOS & OS X Developers Conference\n### Build succeeded.\n\n#pragma mark community is proud to announce #Pragma Conference 2015: the only major event dedicated to iOS and OS X development in Italy. \n\nThere will be two full days of awesome workshops and talks by renowned international speakers.\n\n### Conference Day\n__Saturday, October 10 from 9am to 19pm__\n\nThe Conference Day is dedicated to sessions and networking: 16 speakers on 2 tracks will talk about the most interesting and cutting-edge topics of the Apple world. \n\nIt’s a unique opportunity to meet some of the most influential speakers to learn and discuss about novel frameworks, best practices and the latest development methodologies.\n\n### Workshop Day\n__Friday, October 9 from 9am to 19pm__\n\nA day of practical, in-depth, 6-hours workshops taught by industry experts. The topics will span from consolidated Cocoa technologies and practices to the latest announced APIs, tools and frameworks. \n\nEach workshop will get you from zero to hero on a specific topic, with a hands-on experience and in-depth explanation of advanced details, tips and tricks as learned from the teacher’s experience."
        text2.required = true
        
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
            RealmProvider.eventRealm.add(session3)
            
            RealmProvider.eventRealm.add(text1)
            RealmProvider.eventRealm.add(text2)
        }
        
        let favorites = Favorites()
        favorites.speakers.append(ObjectId(id: speaker1.uuid))
        favorites.sessions.append(ObjectId(id: session2.uuid))
        
        try! RealmProvider.appRealm.write {
            RealmProvider.appRealm.deleteAll()
            RealmProvider.appRealm.add(favorites)
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
