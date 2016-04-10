//
//  DataImport.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 4/10/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import Foundation
import RealmSwift
import AFDateHelper

func day1(hr: Double) -> NSDate {
    let hour = Int(hr)
    let minutes = Double(hr - Double(hour)) * 100
    
    return NSDate(fromString: "2016-04-25", format: DateFormat.ISO8601(.Date), timeZone: TimeZone.UTC)
        .dateByAddingHours(hour).dateByAddingMinutes(Int(minutes))
}

func day2(hr: Double) -> NSDate {
    return day1(hr).dateByAddingHours(24)
}

func lenInMinutes(d1: NSDate , d2: NSDate) -> Int {
    return Int((d2.timeIntervalSinceReferenceDate - d1.timeIntervalSinceReferenceDate) / 60)
}

class DataImport: DataImporter {
    
    static func dataImport() {
        let realm = RealmProvider.eventRealm
        
        let event = EventData()
        event.title = "App Builders Switzerland"
        event.subtitle = ""
        event.organizer = "Junior Bontognali, Patrick Balestra, Dylan Marriott, John Riordan, Luca Scuderi"
        event.logo = UIImage(named: "appbuilders/logo.png")
        event.twitterTag = "#appbuilders16"
        event.twitterAdmin = "@appbuilders_ch"
        event.mainColor = UIColor(hexString: "e43632")
        event.twitterChatter = false
        
        let location1 = Location()
        location1.location = "AWL Room"
        
        let location2 = Location()
        location2.location = "PerfectApp Room"
        
        let track1 = Track()
        track1.track = "AWL Room"
        
        let track2 = Track()
        track2.track = "PerfectApp Room"

        try! realm.write {
            realm.deleteAll()
            
            let adrian = Speaker(value: [
                "name": "Adrian Kosmaczewski",
                "bio": "Adrian has been waking up every day for the past 18 years with the hope of learning something new before dusk. In the meantime he wrote two books, taught software development in three continents, started and ended his own business, and shipped software for iOS, OS X, Windows and Linux. Every year he learns a new programming language and reads at least 6 books about programming. He features obsessive personality traits, often derided, sometimes lauded and also attacked – but never ignored.",
                "twitter": "akosma",
                "_photo": UIImage(named: "appbuilders/adrian.jpg")!.dataValue!
                ])
            realm.add(adrian)
            
            let damian = Speaker(value: [
                "name": "Damian Mehers",
                "bio": "Damian Mehers works as a software developer and consultant, based near Geneva, Switzerland. He’s provided consulting to companies as varied as Swisscom in Bern, Tetra Pak in Lausanne, and Evernote in California.\n\nMost recently as part of a five-year consulting engagement with Evernote he created the original Evernote Windows Phone app, and worked on Evernote products for Android. He created and refined Evernote’s Wearables strategy, having created Evernote for the Samsung Galaxy Gear, Sony Smart Watch, the Pebble Smartwatch, and Android Wear. As part of that work he also explored and developed for Google Glass, Apple Watch and more.\n\nDamian is intrigued by the possibilities afforded by Virtual and Augmented Reality beyond the world of games to transform the ways we interact with computers in ways we are just starting to imagine. He is actively exploring this space.\n\nHe has founded and sold several successful software companies, and loves the magic that is creating software products: turning something imagined into something real.",
                "twitter": "DamianMehers",
                "_photo": UIImage(named: "appbuilders/damian.jpg")!.dataValue!
                ])
            realm.add(damian)
            
            let natasha = Speaker(value: [
                "name": "Natasha Murashev",
                "bio": "Natasha is an iOS developer by day and a robot by night. She blogs about Swift, WatchOS, and iOS development on her blog, natashatherobot.com, and curates a fast-growing weekly Swift newsletter.\n\nShe's currently living the digital nomad life as her alter identity: @NatashaTheNomad.",
                "twitter": "NatashaTheRobot",
                "_photo": UIImage(named: "appbuilders/natasha.jpg")!.dataValue!
                ])
            realm.add(natasha)

            let enrique = Speaker(value: [
                "name": "Enrique López Mañas",
                "bio": "Enrique is a Google Developer Expert, and IT Consultor normally based in Munich, Germany (although is hard to catch him up there for more than a few weeks). He develops software and writes about it for money and fun. He spends his free time developing OpenSource code, writing articles, learning languages or taking photographies. He loves nature, beer, traveling, and talking about him in third person.\n\nYou can contact him on @eenriquelopez in Twitter and +EnriqueLópezMañas in G+.",
                "twitter": "eenriquelopez",
                "_photo": UIImage(named: "appbuilders/enrique.jpg")!.dataValue!
                ])
            realm.add(enrique)

            let anastasiia = Speaker(value: [
                "name": "Anastasiia Voitova",
                "bio": "Anastasiia is building iOS applications for several years, participating in full lifecycle: from gathering business demands and cost estimation, through ux prototyping to developing and long-term supporting. Often builds both client and server sides and shares her knowledge with community from both sides of barricades.\n\nGot into computer security and cryptography when she was invited to fix a few lines of code in iOS port of cryptographic library, ended up taking over of all iOS development and some general mobile ideology part of the project.\n\nPhysically lives in Kyiv, Ukraine, spends her time online twiting as @vixentael.",
                "twitter": "vixentael",
                "_photo": UIImage(named: "appbuilders/anastasiia.png")!.dataValue!
                ])
            realm.add(anastasiia)

            let cesar = Speaker(value: [
                "name": "César Valiente",
                "bio": "César Valiente is currently working at Microsoft, in the Wunderlist team, the makers of the famous and awarded multi-platform productivity app, as Android Engineer. His current focus is on make Wunderlist for Android better, working on the core of the app improving the current code base.\n\nCésar is recognized by Google as Android Google Developer Expert (GDE).\n\nHe is a community guy, he actively supports GDG communities and local meet-ups, giving talks, helping organizing events, etc. \nHe is a FLOSS (Free/Libre Open Source Software) expert and advocate.\n\nAs an avid speaker, he thinks that sharing knowledge with the community is something really great and important, so he has spoken in some of the most important mobile/Android related conferences along EMEA.",
                "twitter": "CesarValiente",
                "_photo": UIImage(named: "appbuilders/cesar.jpg")!.dataValue!
                ])
            realm.add(cesar)

            let marin = Speaker(value: [
                "name": "Marin Todorov",
                "bio": "Marin Todorov is an independent iOS consultant and publisher. He’s the author of the \"iOS Animations by Tutorials\" book and runs the \"iOS Animations by Emails\" newsletter.\n\nHe started developing on an Apple ][ more than 20 years ago and keeps rocking till today. Meanwhile he has worked in great companies like Monster Technologies and Native Instruments, has lived in 4 different countries, and is one the founding members of the raywenderlich.com tutorial team.\n\nBesides crafting code, Marin also enjoys blogging, writing books, teaching, and speaking. He sometimes open sources his code. He walked the way to Santiago.",
                "twitter": "icanzilb",
                "_photo": UIImage(named: "appbuilders/marin.jpg")!.dataValue!
                ])
            realm.add(marin)

            let chris = Speaker(value: [
                "name": "Chris Lüscher",
                "bio": "Chris studied Sociology, Computational Linguistics and Chinese in Zurich and Paris. He started off as an online project manager for Switzerland’s leading publishing house Tamedia in 2000. During his time at Tamedia, he co-founded and worked for a total of 8 Internet platforms and managed several other projects. Chris founded the Zurich branch of iA in 2009.\n\niA runs offices in Zurich and Tokyo. iA has set new standards in interaction design with clients like The Guardian, Monotype and NHK and its best selling text editor called iA Writer.",
                "twitter": "iA_Chris",
                "_photo": UIImage(named: "appbuilders/chris.jpg")!.dataValue!
                ])
            realm.add(chris)

            let sebastian = Speaker(value: [
                "name": "Sebastian Vieira",
                "bio": "Sebastian Vieira is a software engineer specialized in iOS and Android development. He currently works for local.ch as senior software engineer and he is member of the team responsible of the development of mobile apps.\n\nHe is also the founder of iPhonso, where he creates apps for iOS. Some of them have reached high levels of popularity and are being used by thousands of users every day.\n\nDuring his career he has had many roles, which range from software engineer to director of technology, as well as managing offshore teams in India and East Europe.\n\nSebastian has a Master of Science in Software Engineering by the UAM, Madrid. He has done one year of postgraduate studies at the Faculty of Computer Science in Helsinki, Finland.",
                "twitter": "seviu",
                "_photo": UIImage(named: "appbuilders/sebvieira.png")!.dataValue!
                ])
            realm.add(sebastian)

            let graham = Speaker(value: [
                "name": "Graham Lee",
                "bio": "Graham wrote a few apps and a couple of books so that other people could write a few apps too.\n\nAfter realising how much of a workaholic he had become, he decided to give up workahol.",
                "twitter": "iwasleeg",
                "_photo": UIImage(named: "appbuilders/graham.jpg")!.dataValue!
                ])
            realm.add(graham)

            let alexsander = Speaker(value: [
                "name": "Alexsander Akers",
                "bio": "Alex currently works for Shutterstock in their Berlin office, where he develops their iOS apps for both stock media consumers and producers.\n\nPreviously, Alex worked at Branch in New York City on Potluck and then at Facebook in London on Rooms and React Native.",
                "twitter": "a2",
                "_photo": UIImage(named: "appbuilders/a2.jpg")!.dataValue!
                ])
            realm.add(alexsander)

            let etienne = Speaker(value: [
                "name": "Etienne Studer",
                "bio": "Etienne works at Gradle Inc. as VP of Product Tooling, co-leading the development efforts of Gradle.com. He has been working as a developer, architect, project manager, and CTO over the past 15 years. Etienne has spent most of his time building software products from the ground up and successfully shipping them to happy customers.\n\nHe had the privilege to work in different domains like linguistics, banking, insurance, logistics, and process management. Etienne used to share his passion for high-productivity tools as an evangelist for JetBrains. He was also a founding member of the JetBrains Development Academy and of Hackergarten. In his little spare time, Etienne maintains several popular Gradle plugins.",
                "twitter": "etiennestuder",
                "_photo": UIImage(named: "appbuilders/etienne.jpg")!.dataValue!
                ])
            realm.add(etienne)
            
            let orta = Speaker(value: [
                "name": "Orta Therox",
                "bio": "Orta Therox is the self-proclaimed Design Dictator on the Cocoa dependency manager, CocoaPods. He runs the Artsy mobile team, with the aim at making a lasting impact on the art world. The team works on the principal of Open Source by Default, you can check it out in our objc.io.",
                "twitter": "orta",
                "_photo": UIImage(named: "appbuilders/orta.png")!.dataValue!
                ])
            realm.add(orta)
            
            let daniel = Speaker(value: [
                "name": "Daniel H. Steinberg",
                "bio": "Daniel Steinberg is a podcaster, author, editor, trainer, and developer at Dim Sum Thinking.",
                "twitter": "dimsumthinking",
                "_photo": UIImage(named: "appbuilders/dimsum.png")!.dataValue!
                ])
            realm.add(daniel)
            
            let vikram = Speaker(value: [
                "name": "Vikram Kriplaney",
                "bio": "Vikram has been a mobile developer since when WAP was still cool and Symbian and J2ME were still fashionable. He founded mobile at local.ch in 2007, where he went on to singlehandedly develop massively successful mobile web, iOS and Android apps. In due course, he helped build one of the most awesome mobile engineering teams in Switzerland.\n\nHe's very Spanish, very Indian and increasingly Swiss – having grown up between Gran Canaria and Mumbai, he calls Zurich home.\n\nNowadays, you'll find him raving madly about Swift, while nurturing crazy app ideas at iPhonso.",
                "twitter": "krips",
                "_photo": UIImage(named: "appbuilders/vikram.png")!.dataValue!
                ])
            realm.add(vikram)
            
            let lorica = Speaker(value: [
                "name": "Lorica Claesson",
                "bio": "Lorica is a UX Designer with a twist, having both a design and technical background.\n\nShe is passionate about innovative desktop, web and mobile applications that are tailored for real users. Designing engaging and easy-to-use interfaces backed up by a solid technical understanding of what is feasible and using a range of methods for understanding what users really want and need.\n\nLorica works as a UX design consultant in Zurich specializing in mobile design, with a rare interest for designing Android apps.",
                "twitter": "",
                "_photo": UIImage(named: "appbuilders/lorica.png")!.dataValue!
                ])
            realm.add(lorica)
            
            let vitaly = Speaker(value: [
                "name": "Vitaly Friedman",
                "bio": "Vitaly Friedman loves beautiful content and does not give up easily. From Minsk in Belarus, he studied computer science and mathematics in Germany, discovered the passage a passion for typography, writing and design. After working as a freelance designer and developer for 6 years, he co-founded Smashing Magazine, a leading online magazine dedicated to design and web development. Vitaly is the author, co-author and editor of all Smashing books. He currently works as editor-in-chief of Smashing Magazine in the lovely city of Freiburg, Germany.",
                "twitter": "smashingmag",
                "_photo": UIImage(named: "appbuilders/vitaly.png")!.dataValue!
                ])
            realm.add(vitaly)
            
            let maxim = Speaker(value: [
                "name": "Maxim Cramer",
                "bio": "iOS Developer and Designer.",
                "twitter": "mennenia",
                "_photo": UIImage(named: "appbuilders/maxim.jpg")!.dataValue!
                ])
            realm.add(maxim)
            
            let kevin = Speaker(value: [
                "name": "Kevin Goldsmith",
                "bio": "Kevin Goldsmith is a Vice President of Engineering at Spotify AB in Stockholm, Sweden where he is responsible for the product engineering organization; a team of 140 developers, testers, and coaches. Previously, he was a Director of Engineering at Adobe Systems for nine years, where he led the Adobe Revel product group and the Adobe Image Foundation group.\n\nHe spent eight years at Microsoft, where he was a member of the Windows Media, Windows CE CoreOS and Microsoft Research teams. He has also worked at such companies as Silicon Graphics, (Colossal) Pictures, Agnostic Media and IBM.\n\nHe has a degree in Applied Mathematics and Computer Science from Carnegie Mellon University.",
                "twitter": "KevinGoldsmith",
                "_photo": UIImage(named: "appbuilders/kevin.png")!.dataValue!
                ])
            realm.add(kevin)
            
            let sally = Speaker(value: [
                "name": "Sally Shepard",
                "bio": "Sally Shepard is an iOS developer, accessibility consultant and hardware hacker who has worked on a wide variety of award winning apps. Before the iPhone existed, she studied audio engineering, a field which combined her love of music and tinkering with expensive hardware.\n\nShe lives in London and in her spare time she enjoys hacking, playing banjo and taking pictures with vintage cameras.",
                "twitter": "mostgood",
                "_photo": UIImage(named: "appbuilders/sally.jpg")!.dataValue!
                ])
            realm.add(sally)
            
            let jp = Speaker(value: [
                "name": "JP Simard",
                "bio": "Objective-C & Swift developer at Realm",
                "twitter": "simjp",
                "_photo": UIImage(named: "appbuilders/jp.jpg")!.dataValue!
                ])
            realm.add(jp)
            
            let sergi = Speaker(value: [
                "name": "Sergi Martinez",
                "bio": "Sergi is the Mobility R+D lead of Schibsted Spain, before that, he worked leading several Android teams. He also worked many years in the localisation industry.\n\nHe's a fan of communities and collaborated with many of them, also he was one the founders of Catdroid, the Catalonia Android Community.\n\nLast year he was honored as GDE (Google Developer Expert) on Android by Google for his contribution to the Android community.",
                "twitter": "SergiAndReplace",
                "_photo": UIImage(named: "appbuilders/sergi.jpg")!.dataValue!
                ])
            realm.add(sergi)
            
            let preben = Speaker(value: [
                "name": "Preben Thorø",
                "bio": "Preben has been with Trifork since the early days, and over the past years, he has been part of establishing Trifork GmbH in Zurich and lately The Perfect App Ltd. During his +15 years in the business he has taken various positions and roles like programmer/developer, consultant, project manager, team leader, coach and more.\n\nHe has a strong focus on user experience and making people working efficiently together to meet the end user needs. Preben's main technical focus lies on the mobile platforms, but being a spare time electronics hacker, it often involves the combination of sensors, gadgets, and a mobile phone.",
                "twitter": "",
                "_photo": UIImage(named: "appbuilders/preben.png")!.dataValue!
                ])
            realm.add(preben)
            
            let sangsoo = Speaker(value: [
                "name": "Sangsoo Nam",
                "bio": "Sangsoo is passionate about learning, discussing, and solving interesting problems. In the past, Sangsoo worked as a full stack developer in the start-up industry. \n\nThese days, Sangsoo is focusing on the Android development at Spotify. As we know, software industry is changed really rapidly. Sangsoo strongly believe that everyone is solving their problem creatively. Sangsoo looks forward to opportunities to share my lessons and listen to lessons from others.",
                "twitter": "sangsoonam",
                "_photo": UIImage(named: "appbuilders/sangsoo.jpg")!.dataValue!
                ])
            realm.add(sangsoo)
            
            let nicolas = Speaker(value: [
                "name": "Nicolas Seriot",
                "bio": "Nicolas Seriot has been working as a Cocoa developer for more than 10 years in the Lausanne area.\n\nHe is best known for his early research on iOS Privacy (2009), the STTwitter Obj-C library (2013) and the iOS-Runtime-Headers repository.\n\nIn the past three years, Nicolas got especially interested in how digital stuff can get over-complicated when trying to fit with analog human life.\n\nThat's why his latest talks were about Unicode, and about the way computers deal with the concept of time.\n\nWhen not managing Swissquote Bank's mobile team, Nicolas is most likely running, cooking, parenting or pushing Swift code on GitHub.",
                "twitter": "nst021",
                "_photo": UIImage(named: "appbuilders/nicolas.jpg")!.dataValue!
                ])
            realm.add(nicolas)
            
            let andreas = Speaker(value: [
                "name": "Andreas Vourkos",
                "bio": "Andreas is a mobile software engineer at Pollfish building its SDKs for different platforms. He has been developing mobile apps since the early days of feature phones with J2ME and has a strong interest in mobile monetization tactics and trends and how they are applied in an app’s design.\n\nAlways curious about innovative mobile products that can reach massive scale and improve the lives of millions.",
                "twitter": "vourkosa",
                "_photo": UIImage(named: "appbuilders/andreas.png")!.dataValue!
                ])
            realm.add(andreas)
            
            let john = Speaker(value: [
                "name": "John Sundell",
                "bio": "John has been building apps, tools and games for Apple's platforms since the early days of the iOS SDK. For the last 3 years, he's been working at Spotify, where he is currently leading a project to make the iOS app more dynamic and faster to develop for.\n\nJohn is also a huge fan of Swift, spending a large part of his spare time hacking away on open source projects, games and tools using it.",
                "twitter": "johnsundell",
                "_photo": UIImage(named: "appbuilders/john.jpg")!.dataValue!
                ])
            realm.add(john)
            
            let steve = Speaker(value: [
                "name": "Steve Scott",
                "bio": "Scotty has been a freelance developer since 1992 although he is probably best known for being the host on a number of developer podcasts including Late Night Cocoa and The iDeveloper Podcast. He was also the host and creator of NSConference.\n\nHe has been developer since 1987 when he started writing accounting software using COBOL on a Convergent Unix machine using vi as his IDE. (Sorry Emacs people). Since then he has worked on mainframes (ICL, DEC, & IBM), 16bit and 32 bit Windows, .NET and since 2007 OS X and (a little later) iOS . During his career he has learnt (and forgotten) more languages and IDE’s than is possibly healthy for one lifetime.",
                "twitter": "macdevnet",
                "_photo": UIImage(named: "appbuilders/steve.png")!.dataValue!
                ])
            realm.add(steve)
            
            let julien = Speaker(value: [
                "name": "Julien Decot",
                "bio": "Julien Decot is a Silicon Valley veteran with extensive expertise in scaling consumer Web and Mobile businesses. He is the CRO at TextMe, the messaging platform with over 35 million downloads, which allows users to create multiple phone numbers managed from a single account. Prior to to TextMe, Julien was the Director of Business Development at Skype and was also in charge of planning and strategy. Julien was also the Senior Manager of Corporate Strategy at eBay in 2008.\n\nJulien has an MBA in Strategy from Berkeley.",
                "twitter": "zuzulapraline",
                "_photo": UIImage(named: "appbuilders/julien.png")!.dataValue!
                ])
            realm.add(julien)
            
            let tal = Speaker(value: [
                "name": "Tal Heskia",
                "bio": "Tal is the Product Owner for p2pkit at Uepaa - As PO he keeps p2pkit together, makes sure the product is on the right track and is always pointing to the right direction. Tal is highly involved in both ends of the product, from engineering to marketing, and is constantly having internal battles with his engineer v.s. marketeer heads. \n\nBefore becoming a PO, Tal was involved in marketing and mobile applications projects and deployed several apps to the market. In his heart he still enjoys iOS development.",
                "twitter": "uepaa",
                "_photo": UIImage(named: "appbuilders/tal.png")!.dataValue!
                ])
            realm.add(tal)
            
            let ivan = Speaker(value: [
                "name": "Ivan Morgillo",
                "bio": "I started playing with Android in late 2010 as an embedded engineer, then I moved to the “Application layer”, publishing a few pet projects.\n\nMy personal most popular Android app is Gratis Ebooks for Kindle, a Kindle companion app with more than 100k downloads. I like Open Source projects. I’m a big fan of a lot of fancy Android libraries out there and I contribute with bug reporting, fixing and feedback.\n\nI approached Reactive Programming in 2013 and I started using it in Android thanks to RxJava by Netflix. I’m using it in every Android app I work on since then, because RxJava solves so many issues on Android and it gives you a new perspective about mobile programming.\n\nIn 2013 I co-founded Alter Ego, a mobile and embedded solutions company. In 2015 I published RxJava Essentials for Packt Publishing, I'm publishing Learning Embedded Android Programming and I’m currently writing Grokking Rx for Manning Publishing.",
                "twitter": "hamen",
                "_photo": UIImage(named: "appbuilders/ivan.jpg")!.dataValue!
                ])
            realm.add(ivan)
            
            let boris = Speaker(value: [
                "name": "Boris Bügling",
                "bio": "Boris is a Cocoa developer from Berlin, who currently works on the iOS SDK at Contentful.\n\nA Java developer in another life, with many iOS apps under his belt, he is also a strong open source contributor, building plugins to tame Xcode, and bashing bugs as the CocoaPods “Senior VP of Evil”.",
                "twitter": "neonacho",
                "_photo": UIImage(named: "appbuilders/boris.jpg")!.dataValue!
                ])
            realm.add(boris)
            
            let hajan = Speaker(value: [
                "name": "Hajan Selmani",
                "bio": "Entrepreneur and Business Executive with technology-focused mindset. Hajan Selmani is the founder and CEO of HASELT, a software development, design and consulting company focused on providing best-in-class software development services using very latest modern mobile, web and cloud technologies.\n\nHajan is Microsoft MVP 5 years in a row, renowned technology expert, computer scientist and an active community member with hundreds of tech, business and motivational speeches. He is Leader of Macedonian WEB User Group and Board member of MKDOT.NET UG.\n\nNowadays, he focuses on helping his clients and strategic partners to reach business success by combining his technical expertise with business-focused mindset.",
                "twitter": "hajan_s",
                "_photo": UIImage(named: "appbuilders/hajan.jpg")!.dataValue!
                ])
            realm.add(hajan)
            
            let wei = Speaker(value: [
                "name": "Wei Wu",
                "bio": "Wei is a web developer turned iOS developer, and has worked at Yelp for three exciting years on the consumer site and iOS app for business owners. \n\nShe's a San Francisco transplant now living in Hamburg, Germany, confirming the possibility of four seasons a year.",
                "twitter": "wei",
                "_photo": UIImage(named: "appbuilders/wei.jpg")!.dataValue!
                ])
            realm.add(wei)
            
            let appb = Speaker(value: [
                "name": "App Buiders",
                "bio": "A Conference about mobile technologies in the heart of Europe",
                "twitter": "appbuilders_ch",
                "_photo": UIImage(named: "appbuilders/appb.png")!.dataValue!
                ])
            realm.add(appb)
            
            realm.add(event)
            realm.add(location1)
            realm.add(location2)
            realm.add(track1)
            realm.add(track2)
            
            let session1 = Session(value: [
                "title": "Registration",
                "sessionDescription": "",
                "beginTime": day1(8.30),
                "lengthInMinutes": 30,
                "track": track1,
                "location": location1,
                "speakers": [appb]
                ])
            realm.add(session1)
            
            let session2 = Session(value: [
                "title": "Welcome Keynote",
                "sessionDescription": "",
                "beginTime": day1(9),
                "lengthInMinutes": 40,
                "track": track1,
                "location": location1,
                "speakers": [steve]
                ])
            realm.add(session2)
            
            let session3 = Session(value: [
                "title": "Face-Off: iOS for Android Developers, Android for iOS Developers",
                "sessionDescription": "",
                "beginTime": day1(9.45),
                "lengthInMinutes": 30,
                "track": track1,
                "location": location1,
                "speakers": [vikram, sebastian]
                ])
            realm.add(session3)
            
            let session4 = Session(value: [
                "title": "Developing for Apple TV",
                "sessionDescription": "",
                "beginTime": day1(10.20),
                "lengthInMinutes": 30,
                "track": track1,
                "location": location1,
                "speakers": [sally]
                ])
            realm.add(session4)
            
            let session5 = Session(value: [
                "title": "Refactoring Wunderlist for Android",
                "sessionDescription": "",
                "beginTime": day1(10.20),
                "lengthInMinutes": 30,
                "track": track1,
                "location": location2,
                "speakers": [cesar]
                ])
            realm.add(session5)
            
            let session6 = Session(value: [
                "title": "Break",
                "sessionDescription": "",
                "beginTime": day1(10.50),
                "lengthInMinutes": 30,
                "track": track1,
                "location": location1,
                "speakers": [appb]
                ])
            realm.add(session6)
            
            let session7 = Session(value: [
                "title": "SourceKit and You",
                "sessionDescription": "",
                "beginTime": day1(11.20),
                "lengthInMinutes": 30,
                "track": track1,
                "location": location1,
                "speakers": [jp]
                ])
            realm.add(session7)
            
            let session8 = Session(value: [
                "title": "Gradle and the Android Build Platform",
                "sessionDescription": "",
                "beginTime": day1(11.20),
                "lengthInMinutes": 30,
                "track": track1,
                "location": location2,
                "speakers": [etienne]
                ])
            realm.add(session8)
            
            let session9 = Session(value: [
                "title": "Non-technical ways to be a better developer",
                "sessionDescription": "",
                "beginTime": day1(11.55),
                "lengthInMinutes": 50,
                "track": track1,
                "location": location1,
                "speakers": [marin]
                ])
            realm.add(session9)
            
            let session10 = Session(value: [
                "title": "Lunch",
                "sessionDescription": "",
                "beginTime": day1(12.35),
                "lengthInMinutes": lenInMinutes(day1(12.35), d2: day1(14.00)),
                "track": track1,
                "location": location1,
                "speakers": [appb]
                ])
            realm.add(session10)
            
            let session11 = Session(value: [
                "title": "iOS vs. Android: The Mobile OS Deathmatch",
                "sessionDescription": "",
                "beginTime": day1(14.00),
                "lengthInMinutes": 40,
                "track": track1,
                "location": location1,
                "speakers": [chris]
                ])
            realm.add(session11)
            
            let session12 = Session(value: [
                "title": "Building cross platform mobile apps with Xamarin",
                "sessionDescription": "",
                "beginTime": day1(14.45),
                "lengthInMinutes": 40,
                "track": track1,
                "location": location1,
                "speakers": [hajan]
                ])
            realm.add(session12)
            
            let session13 = Session(value: [
                "title": "Designing apps for Android",
                "sessionDescription": "",
                "beginTime": day1(14.45),
                "lengthInMinutes": 40,
                "track": track1,
                "location": location2,
                "speakers": [lorica]
                ])
            realm.add(session13)
            
            let session14 = Session(value: [
                "title": "TBA",
                "sessionDescription": "",
                "beginTime": day1(15.30),
                "lengthInMinutes": 30,
                "track": track1,
                "location": location1,
                "speakers": [alexsander]
                ])
            realm.add(session14)
            
            let session15 = Session(value: [
                "title": "TBA",
                "sessionDescription": "",
                "beginTime": day1(15.30),
                "lengthInMinutes": 30,
                "track": track1,
                "location": location2,
                "speakers": [enrique]
                ])
            realm.add(session15)
            
            let session16 = Session(value: [
                "title": "Break",
                "sessionDescription": "",
                "beginTime": day1(16.00),
                "lengthInMinutes": 20,
                "track": track1,
                "location": location1,
                "speakers": [appb]
                ])
            realm.add(session16)
            
            let session17 = Session(value: [
                "title": "Live Design 🎨",
                "sessionDescription": "",
                "beginTime": day1(16.20),
                "lengthInMinutes": 30,
                "track": track1,
                "location": location1,
                "speakers": [maxim]
                ])
            realm.add(session17)
            
            let session18 = Session(value: [
                "title": "How proximity technologies are revolutionising the mobile experience",
                "sessionDescription": "",
                "beginTime": day1(16.20),
                "lengthInMinutes": 30,
                "track": track1,
                "location": location2,
                "speakers": [tal]
                ])
            realm.add(session18)
            
            let session19 = Session(value: [
                "title": "The Mobile Ad Revolution",
                "sessionDescription": "",
                "beginTime": day1(16.55),
                "lengthInMinutes": 30,
                "track": track1,
                "location": location1,
                "speakers": [julien]
                ])
            realm.add(session19)
            
            let session20 = Session(value: [
                "title": "Being A Developer After 40",
                "sessionDescription": "",
                "beginTime": day1(17.30),
                "lengthInMinutes": 30,
                "track": track1,
                "location": location1,
                "speakers": [adrian]
                ])
            realm.add(session20)
            
            // day 2

            let session21 = Session(value: [
                "title": "TBA",
                "sessionDescription": "",
                "beginTime": day2(9.0),
                "lengthInMinutes": 40,
                "track": track1,
                "location": location1,
                "speakers": [kevin]
                ])
            realm.add(session21)
            
            let session22 = Session(value: [
                "title": "Error Handling",
                "sessionDescription": "",
                "beginTime": day2(9.45),
                "lengthInMinutes": 30,
                "track": track1,
                "location": location1,
                "speakers": [nicolas]
                ])
            realm.add(session22)
            
            let session23 = Session(value: [
                "title": "Building Overlay SDKs - the two-minute integration challenge",
                "sessionDescription": "",
                "beginTime": day2(9.45),
                "lengthInMinutes": 30,
                "track": track1,
                "location": location2,
                "speakers": [andreas]
                ])
            realm.add(session23)
            
            let session24 = Session(value: [
                "title": "Upgrading approaches to the secure mobile architectures",
                "sessionDescription": "",
                "beginTime": day2(10.20),
                "lengthInMinutes": 30,
                "track": track1,
                "location": location1,
                "speakers": [anastasiia]
                ])
            realm.add(session24)
            
            let session25 = Session(value: [
                "title": "Realm or: How I Learned to Stop Worrying and Love my App Database",
                "sessionDescription": "",
                "beginTime": day2(10.20),
                "lengthInMinutes": 30,
                "track": track1,
                "location": location2,
                "speakers": [sergi]
                ])
            realm.add(session25)
            
            let session26 = Session(value: [
                "title": "Break",
                "sessionDescription": "",
                "beginTime": day2(10.50),
                "lengthInMinutes": 30,
                "track": track1,
                "location": location1,
                "speakers": [appb]
                ])
            realm.add(session26)
            
            let session27 = Session(value: [
                "title": "Dynamic, native, backend-driven UIs",
                "sessionDescription": "",
                "beginTime": day2(11.20),
                "lengthInMinutes": 30,
                "track": track1,
                "location": location1,
                "speakers": [john]
                ])
            realm.add(session27)
            
            let session28 = Session(value: [
                "title": "When buzzwords collide: Combining Wearables and Virtual Reality on Android",
                "sessionDescription": "",
                "beginTime": day2(11.20),
                "lengthInMinutes": 30,
                "track": track1,
                "location": location2,
                "speakers": [damian]
                ])
            realm.add(session28)
            
            let session29 = Session(value: [
                "title": "Moving to OSS by Default",
                "sessionDescription": "",
                "beginTime": day2(11.55),
                "lengthInMinutes": 40,
                "track": track1,
                "location": location1,
                "speakers": [orta]
                ])
            realm.add(session29)
            
            let session30 = Session(value: [
                "title": "Lunch",
                "sessionDescription": "",
                "beginTime": day2(12.35),
                "lengthInMinutes": lenInMinutes(day2(12.35), d2: day2(14.00)),
                "track": track1,
                "location": location1,
                "speakers": [appb]
                ])
            realm.add(session30)
            
            let session31 = Session(value: [
                "title": "Cutting-Edge Responsive Web Design",
                "sessionDescription": "",
                "beginTime": day2(14.00),
                "lengthInMinutes": 40,
                "track": track1,
                "location": location1,
                "speakers": [vitaly]
                ])
            realm.add(session31)
            
            let session32 = Session(value: [
                "title": "Apple's Best Programming Language",
                "sessionDescription": "",
                "beginTime": day2(14.45),
                "lengthInMinutes": 40,
                "track": track1,
                "location": location1,
                "speakers": [graham]
                ])
            realm.add(session32)
            
            let session33 = Session(value: [
                "title": "Android Reactive Programming with RxJava",
                "sessionDescription": "",
                "beginTime": day2(14.45),
                "lengthInMinutes": 40,
                "track": track1,
                "location": location2,
                "speakers": [ivan]
                ])
            realm.add(session33)
            
            let session34 = Session(value: [
                "title": "Practical Protocol-Oriented Programming in Swift",
                "sessionDescription": "",
                "beginTime": day2(15.30),
                "lengthInMinutes": 30,
                "track": track1,
                "location": location1,
                "speakers": [natasha]
                ])
            realm.add(session34)
            
            let session35 = Session(value: [
                "title": "Application Architecture for Scaled Agile",
                "sessionDescription": "",
                "beginTime": day2(15.30),
                "lengthInMinutes": 30,
                "track": track1,
                "location": location2,
                "speakers": [sangsoo]
                ])
            realm.add(session35)
            
            let session36 = Session(value: [
                "title": "Break",
                "sessionDescription": "",
                "beginTime": day2(16.00),
                "lengthInMinutes": 20,
                "track": track1,
                "location": location1,
                "speakers": [appb]
                ])
            realm.add(session36)
            
            let session37 = Session(value: [
                "title": "The Open World of Swift 3",
                "sessionDescription": "",
                "beginTime": day2(16.20),
                "lengthInMinutes": 30,
                "track": track1,
                "location": location1,
                "speakers": [daniel]
                ])
            realm.add(session37)
            
            let session38 = Session(value: [
                "title": "Simple Psychology as the Key to Better User Experience",
                "sessionDescription": "",
                "beginTime": day2(16.20),
                "lengthInMinutes": 30,
                "track": track1,
                "location": location2,
                "speakers": [preben]
                ])
            realm.add(session38)
            
            let session39 = Session(value: [
                "title": "iOS Styleguides: Ensuring Visual Consistency and Modular Code",
                "sessionDescription": "",
                "beginTime": day2(16.55),
                "lengthInMinutes": 30,
                "track": track1,
                "location": location1,
                "speakers": [wei]
                ])
            realm.add(session39)
            
            let session40 = Session(value: [
                "title": "Cross-platform Swift",
                "sessionDescription": "",
                "beginTime": day2(16.55),
                "lengthInMinutes": 30,
                "track": track1,
                "location": location2,
                "speakers": [boris]
                ])
            realm.add(session40)
            
            let session41 = Session(value: [
                "title": "Wake Up! The future is now",
                "sessionDescription": "Nina Vutk",
                "beginTime": day2(17.30),
                "lengthInMinutes": 15,
                "track": track1,
                "location": location1,
                "speakers": [appb]
                ])
            realm.add(session41)
            
            let session42 = Session(value: [
                "title": "Closing",
                "sessionDescription": "",
                "beginTime": day2(17.45),
                "lengthInMinutes": 15,
                "track": track1,
                "location": location1,
                "speakers": [appb]
                ])
            realm.add(session42)
        }
    }
}
