//
//  SpeakersModel.swift
//  EventBlank
//
//  Created by Marin Todorov on 9/21/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import RealmSwift

typealias ScheduleDaySection = [String: [Speaker]]

extension CollectionType {
    
    typealias ItemType = Self.Generator.Element
    typealias SectionItemType = SectionModel<String, ItemType>

    func breakIntoSections(breakCondition: (ItemType, ItemType?) -> String?) -> [SectionItemType] {
        
        var items: [SectionItemType] = []
        var currentSectionItems: [ItemType] = []
            
        var index = self.startIndex
        while index != endIndex {
            currentSectionItems.append(self[index])
            
            let nextItem: Self.Generator.Element? = index.distanceTo(endIndex) > 1 ? self[index.successor()] : nil
            
            if let newSectionTitle = breakCondition(self[index], nextItem) {
                //add section
                
                items.append(SectionItemType(model: newSectionTitle, items: currentSectionItems))
                
                //reset current items
                currentSectionItems = []
            }

            index = index.successor()
        }
        
        return items
    }
}

class SpeakersModel {
    
    var items: [SectionModel<String, Speaker>] = []

    var searchTerm: String? {
        didSet {
            if searchTerm == nil {
                
            }
        }
    }
    
    var favorites: [Int]!
    var filterOnlyFavorites = false
    
//    var isFiltering: Bool {
////        let result = (searchTerm.characters.count > 0) || filterOnlyFavorites
//        return result
//    }

//    private var totalNumberOfItems = 0
//    private var filteredNumberOfItems = 0
    
    //MARK: - load
    
    func load(searchTerm term: String = "", showOnlyFavorites: Bool = false) {
        //update current settings
        searchTerm = term
        filterOnlyFavorites = showOnlyFavorites
        
        //find the relevant results
        //totalNumberOfItems = 0
        
        //load speakers
        let speakers = RealmProvider.eventRealm.objects(Speaker).sorted(Speaker.name)
        items = speakers.breakIntoSections(sectionTitleWithSpeakers)
    }
    
    func sectionTitleWithSpeakers(speaker1: Speaker, speaker2: Speaker?) -> String? {
        guard let speaker2 = speaker2 else {
            return String(speaker1.name[0])
        }
        
        return (String(speaker1.name[0]) != String(speaker2.name[0])) ? String(speaker1.name[0]) : nil
    }
    
    // MARK: - filter
    
//    func filterItemsWithTerm(term: String?, favorites: Bool = false) {
//        searchTerm = term ?? ""
//        filterOnlyFavorites = favorites
//        
//        var results = [Speaker]()
//
//        for section in items {
//            for row in section.values.first! {
//                var eligibleResult = true
////                if favorites {
////                    if self.favorites.indexOf(row[Speaker.idColumn]) == nil {
////                        eligibleResult = false
////                    }
////                }
//                if let term = term {
//                    if !(row.name).contains(term, ignoreCase: true) {
//                        eligibleResult = false
//                    }
//                }
//                if eligibleResult {
//                    results.append(row)
//                }
//            }
//        }
//        let searchSection: SpeakerSection = ["search": results]
//        items = [searchSection]
//    }
    
    // MARK: - favorites
    
//    func isFavorite(speakerId speakerId: Int) -> Bool {
//        return favorites.indexOf(speakerId) != nil
//    }
//    
//    func addFavorite(speakerId speakerId: Int) {
//        favorites.append(speakerId)
//        Favorite.saveSpeakerId(speakerId)
//    }
//
//    func removeFavorite(speakerId speakerId: Int) {
//        if let currentSpeakerIndex = favorites.indexOf(speakerId) {
//            favorites.removeAtIndex(currentSpeakerIndex)
//        }
//        Favorite.removeSpeakerId(speakerId)
//    }
//    
//    func refreshFavorites() {
//        favorites = Favorite.allSpeakerFavoriteIDs()
//    }
}