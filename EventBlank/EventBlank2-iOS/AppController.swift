//
//  AppController.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 3/4/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import Foundation
import Reachability

class AppController {
    
    let interactor = Interactor()
    let reachability = try! Reachability(hostname: "google.com")
    let realm = RealmProvider()
    
}