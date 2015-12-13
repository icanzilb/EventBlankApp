//
//  OrderedMap.swift
//  EventBlank
//
//  Created by Marin Todorov on 7/13/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import Foundation

struct OrderedMap<TK: Hashable, TV> {
    
    typealias ArrayType = [TK]
    typealias DictionaryType = [TK: TV]
    
    var array = ArrayType()
    var dictionary = DictionaryType()
    
    var count: Int {
        return array.count
    }
    
    private var nextIndex = 0
    
    subscript(key: TK) -> TV? {
        get {
            return self.dictionary[key]
        }
        
        set {
            if array.indexOf(key) > -1  {
               array.append(key)
            }
            
            self.dictionary[key] = newValue
        }
    }
    
    subscript(index: Int) -> (TK, TV) {
        get {
            return (array[index], dictionary[array[index]]!)
        }
        
        set {
            array.insert(newValue.0, atIndex: index)
            dictionary[newValue.0] = newValue.1
        }
    }
    
}

extension OrderedMap: GeneratorType {
    
    mutating func next() -> (TK, TV)? {
        if (nextIndex >= count) {
            return nil
        }
        
        return self[nextIndex++]
    }
}

extension OrderedMap: SequenceType {
    
    func generate() -> OrderedMap {
        return self
    }
}