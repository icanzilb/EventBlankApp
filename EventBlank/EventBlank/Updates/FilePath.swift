//
//  FilePath.swift
//  EventBlank
//
//  Created by Marin Todorov on 7/13/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import Foundation

struct FilePath: Printable {
    
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
        return (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first as! String).stringByAppendingPathComponent(fileName)
    }
    
    internal static func inLibrary(fileName: String) -> String {
        return (NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true).first as! String).stringByAppendingPathComponent(fileName)
    }
    
    internal static func inBundle(fileName: String) -> String? {
        return NSBundle.mainBundle().pathForResource(fileName, ofType: nil)
    }
    
    //MARK: - compare modification dates
    func isItemNewerThanItemAtPath(toPath: FilePath) -> Bool {
        
        let manager = NSFileManager.defaultManager()
        
        if  let atAttributes = manager.attributesOfItemAtPath(self.filePath, error: nil),
            let atModDate = atAttributes[NSFileModificationDate] as? NSDate,
            let toAttributes = manager.attributesOfItemAtPath(toPath.filePath, error: nil),
            let toModDate = toAttributes[NSFileModificationDate] as? NSDate
        {
            return atModDate.compare(toModDate) == NSComparisonResult.OrderedDescending
        } else {
            return false
        }
    }
    
    //MARK: - copy functions
    
    func copyOnceTo(toPath: FilePath) {
        let manager = NSFileManager.defaultManager()
        
        if manager.fileExistsAtPath(toPath.filePath) == false {
            println("copy \(self) to \(toPath)")
            copyAndReplaceItemToPath(toPath, error: nil)
        }
    }
    
    func copyIfNewer(toPath: FilePath) {
        if isItemNewerThanItemAtPath(toPath) {
            copyAndReplaceItemToPath(toPath, error: nil)
        }
    }
    
    func copyAndReplaceItemToPath(toPath: FilePath, error: NSErrorPointer?) -> Bool {
        var result = false
        
        var deleteError: NSError?
        var copyError: NSError?
        
        let manager = NSFileManager.defaultManager()
        
        if manager.fileExistsAtPath(toPath.filePath) {
            println("file exists! delete it first")
            
            if manager.removeItemAtPath(toPath.filePath, error: &deleteError) == false {
                println("failed to delete file: \(deleteError?.localizedDescription)")
                error?.memory = deleteError
            }
        }
        
        if manager.copyItemAtPath(self.filePath, toPath: toPath.filePath, error: &copyError) {
            result = true
        } else {
            println("failed to copy file: \(copyError?.localizedDescription)")
            error?.memory = copyError
        }
        
        return result
    }
}