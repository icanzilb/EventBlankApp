//
//  CollectionType.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 2/22/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import Foundation

import RxDataSources

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
