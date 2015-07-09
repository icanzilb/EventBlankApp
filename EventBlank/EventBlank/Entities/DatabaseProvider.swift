//
//  Database.swift
//  EventBlank
//
//  Created by Marin Todorov on 3/12/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import Foundation
import SQLite

class DatabaseProvider {
  
  var filePath: String!
  var _database: Database
  
  var database: Database {
    return _database
  }
  
    static var databases = [String: Database]()
    
  init?(filePath: String, defaultPath: String? = nil) {

    if let defaultPath = defaultPath {
        defaultPath.moveOnceTo(filePath)
    }
    
    self.filePath = filePath
    _database = Database(self.filePath)
    
    DatabaseProvider.databases[filePath.lastPathComponent] = _database
  }
  
}