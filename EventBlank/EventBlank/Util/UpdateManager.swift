//
//  UpdateManager.swift
//  EventBlank
//
//  Created by Marin Todorov on 7/13/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import Foundation

class UpdateManager: NSObject {
    
    var updateCheckInterval = 1.0 * 15.0
    
    var fileBinder: FreshFile
    
    init(filePath path: FilePath, remoteURL: NSURL, autostart: Bool = true) {
        
        fileBinder = FreshFile(localURL: NSURL(fileURLWithPath: path.filePath)!, remoteURL: remoteURL)
        fileBinder.refreshRate = updateCheckInterval
        
        super.init()

        if autostart {
            delay(seconds: 1.0, {
                self.start()
            })
        }
    }
    
    func start() {
        self.fileBinder.bind()
    }
    
    func stop() {
        self.fileBinder.unbind()
    }
}