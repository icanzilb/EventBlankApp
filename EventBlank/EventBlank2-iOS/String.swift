//
//  String.swift
//  EventBlank
//
//  Created by Marin Todorov on 6/22/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import Foundation

extension String {
    
    subscript (i: Int) -> Character {
        return self.characters[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substringWithRange(startIndex.advancedBy(r.startIndex) ..< startIndex.advancedBy(r.endIndex))
    }
}

extension String {
    public func contains(substring: String,
        ignoreCase: Bool = false,
        ignoreDiacritic: Bool = false) -> Bool {
            
            if substring == "" { return true }
            var options = NSStringCompareOptions()
            
            if ignoreCase { options.insert(.CaseInsensitiveSearch) }
            if ignoreDiacritic { options.insert(.DiacriticInsensitiveSearch) }
            
            return rangeOfString(substring, options: options) != nil
    }
}