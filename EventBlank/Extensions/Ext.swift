//
//  Ext.swift
//  EventBlank
//
//  Created by Marin Todorov on 3/12/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import Foundation
import UIKit

extension String {
  func inDocuments() -> String {
    return (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String).stringByAppendingPathComponent(self)
  }
  
  func inLibrary() -> String {
    return (NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true)[0] as! String).stringByAppendingPathComponent(self)
  }
  
  func inBundle() -> String? {
    return NSBundle.mainBundle().pathForResource(self, ofType: nil)
  }
  
  func moveOnceTo(targetFileName: String) {
    let manager = NSFileManager.defaultManager()
    if true || manager.fileExistsAtPath(targetFileName) == false {
      println("copy \(self) to \(targetFileName)")
      manager.copyItemAtPath(self, toPath: targetFileName, error: nil)
    }
  }
  
}

extension NSFileManager {
  func copyAndReplaceItemAtPath(atPath: String, toPath: String, error: NSErrorPointer?) -> Bool {
    var result = false
    
    var deleteError: NSError?
    var copyError: NSError?
    
    if fileExistsAtPath(toPath) {
      println("file exists! delete it first")
      
      if removeItemAtPath(toPath, error: &deleteError) == false {
        println("failed to delete file: \(deleteError?.localizedDescription)")
        error?.memory = deleteError
      }
      
    }
    
    if copyItemAtPath(atPath, toPath: toPath, error: &copyError) {
      result = true
    } else {
      println("failed to copy file: \(copyError?.localizedDescription)")
      error?.memory = copyError
    }
    
    return result
  }
}

func delay(#seconds: Double, completion:()->()) {
    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
    
    dispatch_after(popTime, dispatch_get_main_queue()) {
        completion()
    }
}
