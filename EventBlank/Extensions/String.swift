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
        return self[advance(self.startIndex, i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: advance(startIndex, r.startIndex), end: advance(startIndex, r.endIndex)))
    }
}

extension String {
    public func contains(substring: String,
        ignoreCase: Bool = false,
        ignoreDiacritic: Bool = false) -> Bool {
            
            if substring == "" { return true }
            var options = NSStringCompareOptions.allZeros
            
            if ignoreCase { options |= NSStringCompareOptions.CaseInsensitiveSearch }
            if ignoreDiacritic { options |= NSStringCompareOptions.DiacriticInsensitiveSearch }
            
            return rangeOfString(substring, options: options) != nil
    }
}