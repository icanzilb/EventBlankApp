//
//  SpeakersModel.swift
//  EventBlank
//
//  Created by Marin Todorov on 9/21/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import RealmSwift

typealias SpeakerSection = [String: [Row]]

class SpeakersModel {
    
    var database: Connection {
        return DatabaseProvider.databases[eventDataFileName]!
    }

    private var items = [SpeakerSection]()
    private var filteredItems = [SpeakerSection]()
    
    var currentItems: [SpeakerSection] {
        return isFiltering ? filteredItems : items
    }
    
    var searchTerm: String = ""
    
    var favorites: [Int]!
    var filterOnlyFavorites = false
    
    var isFiltering: Bool {
        let result = (count(searchTerm) > 0) || filterOnlyFavorites
        return result
    }

    private var totalNumberOfItems = 0
    private var filteredNumberOfItems = 0
    
    var currentNumberOfItems: Int {
        return isFiltering ? filteredNumberOfItems : totalNumberOfItems
    }
    
    //MARK: - load
    
    func load(searchTerm term: String = "", showOnlyFavorites: Bool = false) {
        //update current settings
        searchTerm = term
        filterOnlyFavorites = showOnlyFavorites
        
        //find the relevant results
        totalNumberOfItems = 0
        
        var items = [ScheduleDaySection]()
        
        //load speakers
        var rows = database[SpeakerConfig.tableName].order(Speaker.name).map {$0}
        
        //order and group speakers
        var sectionUsers = [Row]()
        var lastUsedLetter = ""
        
        for speaker in rows {
            let firstNameCharacter = speaker[Speaker.name][0...0].uppercaseString
            
            if lastUsedLetter != "" && lastUsedLetter != firstNameCharacter {
                let newSectionTitle = lastUsedLetter
                let newSection: SpeakerSection = [newSectionTitle: sectionUsers]
                items.append(newSection)
                totalNumberOfItems += sectionUsers.count
                sectionUsers = []
            }
            
            sectionUsers.append(speaker)
            lastUsedLetter = firstNameCharacter
        }
        
        if sectionUsers.count > 0 {
            let newSectionTitle = lastUsedLetter
            let newSection: ScheduleDaySection = [newSectionTitle: sectionUsers]
            items.append(newSection)
            totalNumberOfItems += sectionUsers.count
        }
        
        self.items = items
    }
    
    // MARK: - filter
    
    func filterItemsWithTerm(term: String?, favorites: Bool = false) {
        searchTerm = term ?? ""
        filterOnlyFavorites = favorites
        
        var results = [Row]()
        for section in items {
            for row in section.values.first! {
                var eligibleResult = true
                if favorites {
                    if self.favorites.indexOf(row[Speaker.idColumn]) == nil {
                        eligibleResult = false
                    }
                }
                if let term = term {
                    if !(row[Speaker.name]).contains(term, ignoreCase: true) {
                        eligibleResult = false
                    }
                }
                if eligibleResult {
                    results.append(row)
                }
            }
        }
        let searchSection: SpeakerSection = ["search": results]
        filteredItems = [searchSection]
        filteredNumberOfItems = results.count
    }
    
    // MARK: - favorites
    
    func isFavorite(speakerId speakerId: Int) -> Bool {
        return favorites.indexOf(speakerId) != nil
    }
    
    func addFavorite(speakerId speakerId: Int) {
        favorites.append(speakerId)
        Favorite.saveSpeakerId(speakerId)
    }

    func removeFavorite(speakerId speakerId: Int) {
        if let currentSpeakerIndex = favorites.indexOf(speakerId) {
            favorites.removeAtIndex(currentSpeakerIndex)
        }
        Favorite.removeSpeakerId(speakerId)
    }
    
    func refreshFavorites() {
        favorites = Favorite.allSpeakerFavoriteIDs()
    }
}