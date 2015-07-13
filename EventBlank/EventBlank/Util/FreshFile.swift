//
//  FileBind.swift
//  FileBindDemo
//
//  Created by Marin Todorov on 2/4/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import Foundation

//TODO: relatively old Swift code, wait up for Swift 2.0 to rearrange the error handling

class FreshFile: Printable {

    //MARK: - FreshInfo
    struct FreshInfo {
        var etag: String?
        var contentLength: Double?
        var tempPath: String?
    }

    //MARK: - FreshFile properties
    var remoteURL: NSURL!
    var localURL: NSURL!
    
    var refreshRate: Double = 5 * 60.0
    var networkRetryInterval = 0.1 * 60.0
    var replaceRetryInterval = 0.15 * 60.0
    
    var currentModifyDate = NSDate(timeIntervalSince1970: 0.0)
    
    let manager = NSFileManager.defaultManager()
    
    private var currentEtag: String = ""
    
    init(localURL: NSURL, remoteURL: NSURL) {
        self.localURL = localURL
        self.remoteURL = remoteURL
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let lastEtag = defaults.valueForKey("ETAG-\(self.remoteURL.absoluteString)") as? String {
            currentEtag = lastEtag
        }
    }
    
    //MARK: - actions
    var willDownloadFileMap = OrderedMap<String, (FreshInfo)->Bool>()
    var willReplaceFileMap = OrderedMap<String, (FreshInfo)->Bool>()
    var didReplaceFileMap = OrderedMap<String, (Bool)->Void>()
    
    static var actionCounter = 0
    
    func addAction(#willDownloadFile: (FreshInfo)->Bool, withKey: String?) {
        willDownloadFileMap[withKey ?? "default-\(++self.dynamicType.actionCounter)"] = willDownloadFile
    }
    
    func addAction(#willReplaceFile: (FreshInfo)->Bool, withKey: String?) {
        willReplaceFileMap[withKey ?? "default-\(++self.dynamicType.actionCounter)"] = willReplaceFile
    }
    
    func addAction(#didReplaceFile: (Bool)->Void, withKey: String?) {
        didReplaceFileMap[withKey ?? "default-\(++self.dynamicType.actionCounter)"] = didReplaceFile
    }
    
    //MARK: - binding/unbinding
    var running: Bool {
        return isRunning
    }
    
    private var isRunning = false
    private var isDownloading = false
    
    func bind() {
        isRunning = true
        refresh()
    }
    
    func unbind() {
        isRunning = false
        refreshUUID = nil
    }
    
    private var refreshUUID: String?
    
    func refresh() {
        
        let localRefreshUUID = NSUUID().UUIDString
        refreshUUID = localRefreshUUID
        
        //get current modify date
        if let attributes = manager.attributesOfItemAtPath(localURL.path!, error: nil),
            let modDate = attributes[NSFileModificationDate] as? NSDate {
                
                currentModifyDate = modDate
                println("current date \(modDate)")

                var fileInfo = FreshInfo()
                
                if isRemoteURLFresh(&fileInfo) {
                    println("newer version: \(fileInfo)")
                    isDownloading = true
                    downloadFile(info: fileInfo)
                }
                
                delay(seconds: refreshRate, completion: {
                    if self.isRunning && !self.isDownloading && self.refreshUUID == localRefreshUUID {
                        self.refresh()
                    }
                })
        } else {
            fatalError("Couldn't find bind file at: \(localURL.path!)")
        }
    }
    
    func isRemoteURLFresh(inout fileInfo: FreshInfo) -> Bool {
        var result = false
        
        var request = NSMutableURLRequest(URL: remoteURL, cachePolicy: NSURLRequestCachePolicy.ReloadRevalidatingCacheData, timeoutInterval: 60.0)
        request.HTTPMethod = "HEAD"
        
        let semaphore = dispatch_semaphore_create(0)
        
        let dataTask = NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration()).dataTaskWithRequest(request, completionHandler: {data, response, error in
            //println(data)
            //println(response)
            //println(error)
            
            if error != nil {
                
                println("could not HEAD file: \(request.URL). Error: \(error.localizedDescription)")
                
                //retry
                self.scheduleRefresh(after: self.networkRetryInterval)
                
                dispatch_semaphore_signal(semaphore)
                return
            }
            
            if let response = response as? NSHTTPURLResponse {
                //println(response.allHeaderFields)
                
                if let newEtag = response.allHeaderFields["Etag"] as? String {
                    
                    println("compare local \(self.currentEtag) to \(newEtag)")
                    
                    if newEtag  != self.currentEtag {
                        //there is a newer file!
                        println("remote file is newer")
                        
                        //TODO: CHECK IF it's initial fetching of etag
                        
                        fileInfo.etag = newEtag
                        
                        if let contentLength = response.allHeaderFields["Etag"] as? String {
                            fileInfo.contentLength = (contentLength as NSString).doubleValue
                            println("about to download \(fileInfo.contentLength) bytes")
                        }
                        
                        result = true
                    }
                    
                } else {
                    println("Could not fetch last modified date")
                }
                
                dispatch_semaphore_signal(semaphore)
                return
            }
            
            println("error: Not an HTTP response")
            
        })
        
        dataTask.resume()
        
        while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)>0) {
            NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: 0))
        }
        
        return result
    }
    
    //MARK: - download/replace
    
    func downloadFile(var #info: FreshInfo) {
        
        println("will download file")
        
        for (key, handler) in willDownloadFileMap {
            if handler(info) == false {
                return //a handler cancelled the download
            }
        }
        
        let downloadTask = NSURLSession.sharedSession().downloadTaskWithURL(remoteURL, completionHandler: {tempUrl, response, error in
            
            println(tempUrl)
            println(response)
            println(error)
            
            //copy the downloaded file to a temp location
            var tempCopyError: NSError?
            var tempCopyPath = self.localURL.path!.stringByAppendingString(".pending")
            
            if FilePath(tempUrl.path!).copyAndReplaceItemToPath(FilePath(tempCopyPath), error: &tempCopyError) == false {
                //failed to create a temp copy
                self.isDownloading = false
                println("failed to copy temp file: \(tempCopyError?.localizedDescription)")
                return
            }

            info.tempPath = tempCopyPath
            self.replaceFile(info: info)
        })
        
        downloadTask.resume()
    }
    
    func delay(#seconds: Double, completion:()->()) {
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
        
        dispatch_after(popTime, dispatch_get_main_queue()) {
            completion()
        }
    }
    
    var nextRefreshToken = arc4random() % 100_000_000
    
    func scheduleRefresh(#after: Double) {
        
        let myToken = arc4random() % 100_000_000
        nextRefreshToken = myToken
        
        self.delay(seconds: after, completion: {
            if self.nextRefreshToken == myToken {
                self.refresh()
            }
        })
        
    }
    
    func replaceFile(#info: FreshInfo) {
        //try to replace existing file
        println("will replace file")
        
        //check if temp file is still there
        if let tempPath = info.tempPath where manager.fileExistsAtPath(tempPath) == false {
            return //all done
        }
        
        //check if allowed to replace file
        for (key, handler) in self.willReplaceFileMap {
            if handler(info) == false {
                delay(seconds: replaceRetryInterval, completion: {
                    self.replaceFile(info: info)
                })
                return //retry later
            }
        }
        
        var replaceError: NSError?
        let replaceSuccess = FilePath(info.tempPath!).copyAndReplaceItemToPath(FilePath(localURL.path!), error: &replaceError)
        
        println("did replace file")
        isDownloading = false
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue("ETAG-\(self.remoteURL)", forKey: info.etag!)
        defaults.synchronize()
        currentEtag = info.etag!
        
        self.delay(seconds: 0.1, completion: {
            for (key, handler) in self.didReplaceFileMap {
                handler(replaceSuccess)
            }
        })
        
    }
    
    var description: String {
        return "FreshFile: \(localURL.absoluteString!)\n  willReplaceFileMap: \(willReplaceFileMap)\n\n  didReplaceFile: \(didReplaceFileMap)\n\n"
    }
}