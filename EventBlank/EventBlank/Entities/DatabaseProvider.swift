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
    
    var path: FilePath
    var _database: Database!
    
    var database: Database {
        return _database
    }
    
    static var databases = [String: Database]()
    
    init?(path targetPath: FilePath, defaultPath: FilePath? = nil, preferNewerSourceFile: Bool = false) {
        
        if let defaultPath = defaultPath {

            //copy if does not exist in target location
            defaultPath.copyOnceTo(targetPath)
            
            //copy if the bundle contains a newer version
            if preferNewerSourceFile {
                defaultPath.copyIfNewer(targetPath)
            }
        }
        
        path = targetPath
        
        loadDatabaseFile()
    }
    
    private func loadDatabaseFile() {
        _database = Database(path.filePath)
        DatabaseProvider.databases[path.filePath.lastPathComponent] = _database
    }
    
    func didChangeSourceFile(success: Bool) {
        println("reload database: \(path.filePath)")
        loadDatabaseFile()
    }
}