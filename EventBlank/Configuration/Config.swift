//
//  Config.swift
//  EventBlank
//
//  Created by Marin Todorov on 6/19/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import Foundation

//
// database file names
//

let eventDataFileName = "test.realm"
let appDataFileName = "appdata.db"

let initialEtag = "44557d"


//
//
//

enum EventBlankTabIndex: Int {
    case Schedule = 1
    case Feed = 2
    case Speakers = 3
}
