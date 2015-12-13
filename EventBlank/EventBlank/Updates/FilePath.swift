//
//  FilePath.swift
//  EventBlank
//
//  Created by Marin Todorov on 7/13/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import Foundation

struct FilePath: CustomStringConvertible {
    
    //MARK: - properties
    
    var filePath: String
    
    var description: String {return ":\(filePath)"}

    //MARK: - conveniece inits
    
    init(_ path: String) {
        filePath = path
    }
    
    init(inDocuments fileName: String) {
        filePath = self.dynamicType.inDocuments(fileName)
    }
    
    init(inLibrary fileName: String) {
        filePath = self.dynamicType.inLibrary(fileName)
    }
    
    init?(inBundle fileName: String) {
        if let existingFile = self.dynamicType.inBundle(fileName) {
            filePath = existingFile
        } else {
            return nil
        }
    }
    
    //MARK: - internal string path functions
    
    internal static func inDocuments(fileName: String) -> String {
        let folderPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
        return folderPath.stringByAppendingString("/"+fileName)
    }
    
    internal static func inLibrary(fileName: String) -> String {
        let folderPath = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true).first!
        return folderPath.stringByAppendingString("/"+fileName)
    }
    
    internal static func inBundle(fileName: String) -> String? {
        return NSBundle.mainBundle().pathForResource(fileName, ofType: nil)
    }
    
    //MARK: - compare modification dates
    func isItemNewerThanItemAtPath(toPath: FilePath) -> Bool {
        
        let manager = NSFileManager.defaultManager()
        
        if  let atAttributes = try? manager.attributesOfItemAtPath(self.filePath),
            let atModDate = atAttributes[NSFileModificationDate] as? NSDate,
            let toAttributes = try? manager.attributesOfItemAtPath(toPath.filePath),
            let toModDate = toAttributes[NSFileModificationDate] as? NSDate
        {
            return atModDate.compare(toModDate) == NSComparisonResult.OrderedDescending
        } else {
            return false
        }
    }
    
    //MARK: - copy functions
    
    func copyOnceTo(toPath: FilePath) throws {
        let manager = NSFileManager.defaultManager()
        
        if manager.fileExistsAtPath(toPath.filePath) == false {
            print("copy \(self) to \(toPath)")
            try copyAndReplaceItemToPath(toPath)
        }
    }
    
    func copyIfNewer(toPath: FilePath) throws {
        if isItemNewerThanItemAtPath(toPath) {
            try copyAndReplaceItemToPath(toPath)
        }
    }
    
    func copyAndReplaceItemToPath(toPath: FilePath) throws {
        let manager = NSFileManager.defaultManager()
        
        if manager.fileExistsAtPath(toPath.filePath) {
            print("file exists! delete it first")
            
            do {
                try manager.removeItemAtPath(toPath.filePath)
            } catch let error as NSError {
                print("failed to delete file: \(error.description)")
                throw error
            }
        }
        
        do {
            try manager.copyItemAtPath(self.filePath, toPath: toPath.filePath)
        } catch let error as NSError {
            print("failed to copy file: \(error.description)")
            throw error
        }
    }
}