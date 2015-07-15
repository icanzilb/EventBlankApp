//
//  FileBind.swift
//  FileBindDemo
//
//  Created by Marin Todorov on 2/4/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import Foundation

//TODO: relatively old Swift code, wait up for Swift 2.0 to rearrange the error handling

//MARK: - FreshInfo
struct FreshInfo {
    var etag: String?
    var contentLength: Double?
    var tempPath: String?
}

class FreshFile: Printable {

    //MARK: - FreshFile properties
    var remoteURL: NSURL!
    var localURL: NSURL!
    
    var refreshRate: Double = 60.0
    var networkRetryInterval = 20.0
    
    let manager = NSFileManager.defaultManager()
    
    private var currentEtag: String?
    
    init(localURL: NSURL, remoteURL: NSURL) {
        self.localURL = localURL
        self.remoteURL = remoteURL
        
        let defaults = NSUserDefaults.standardUserDefaults()
        currentEtag = defaults.valueForKey("ETAG-\(self.remoteURL.absoluteString)") as? String
    }
    
    //MARK: - actions
    typealias BoolClosure = (Bool)->Void
    
    var willDownloadFileMap = OrderedMap<String, (FreshInfo, BoolClosure)->Void>()
    var willReplaceFileMap = OrderedMap<String, (FreshInfo)->Bool>()
    var didReplaceFileMap = OrderedMap<String, BoolClosure>()
    
    static private var actionCounter = 0
    
    func addAction(#willDownloadFile: (FreshInfo, BoolClosure)->Void, withKey: String?) {
        willDownloadFileMap[withKey ?? "default-\(++self.dynamicType.actionCounter)"] = willDownloadFile
    }
    
    func addAction(#willReplaceFile: (FreshInfo)->Bool, withKey: String?) {
        willReplaceFileMap[withKey ?? "default-\(++self.dynamicType.actionCounter)"] = willReplaceFile
    }
    
    func addAction(#didReplaceFile: BoolClosure, withKey: String?) {
        didReplaceFileMap[withKey ?? "default-\(++self.dynamicType.actionCounter)"] = didReplaceFile
    }
    
    //MARK: - binding/unbinding
    var running: Bool {
        return isRunning
    }
    
    private var isRunning = false
    private var isDownloading = false
    private var refreshUUID: String?

    func bind() {
        isRunning = true
        refresh()
    }
    
    func unbind() {
        isRunning = false
        refreshUUID = nil
    }
    
    func refresh() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.refreshBackground()
        })
    }
    
    func refreshBackground() {
        let localRefreshUUID = NSUUID().UUIDString
        refreshUUID = localRefreshUUID

        if let fileInfo = remoteFileUpdateInfo() {
            println("newer version: \(fileInfo)")
            isDownloading = true
            downloadFile(info: fileInfo)
        }
        
        delay(seconds: refreshRate, completion: {
            if self.isRunning && !self.isDownloading && self.refreshUUID == localRefreshUUID {
                self.refresh()
            }
        })
    }
    
    func remoteFileUpdateInfo() -> FreshInfo? {

        var fileInfo: FreshInfo? = nil
        
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
                self.delay(seconds: self.networkRetryInterval, completion: {
                    println("retry network call")
                    self.refresh()
                })
                
            } else if let response = response as? NSHTTPURLResponse,
                let newEtag = response.allHeaderFields["Etag"] as? String {
                    
                println("compare local \(self.currentEtag) to \(newEtag)")
                
                if newEtag  != self.currentEtag {
                    //there is a newer file!
                    println("remote file is newer")
                    
                    //TODO: CHECK IF it's initial fetching of etag
                    fileInfo = FreshInfo()
                    fileInfo!.etag = newEtag
                    
                    if let contentLength = response.allHeaderFields["Content-Length"] as? String {
                        fileInfo!.contentLength = (contentLength as NSString).doubleValue
                        println("about to download \(fileInfo!.contentLength) bytes")
                    }
                    
                } else {
                    println("event file is up to date")
                }
            }
            
            dispatch_semaphore_signal(semaphore)
        })
        
        dataTask.resume()
        
        while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)>0) {
            NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: 0))
        }
        
        return fileInfo
    }
    
    //MARK: - download/replace
    
    func downloadFile(var #info: FreshInfo) {
        
        println("will download file")
        
        var semaphore = dispatch_semaphore_create(0)
        var shouldContinueWithDownload = true
        
        //ask all interested parties if they allow the download
        for (key, handler) in self.willDownloadFileMap {
            
            handler(info, {result in
                shouldContinueWithDownload = shouldContinueWithDownload && result
                dispatch_semaphore_signal(semaphore)
            })
            
            //wait for the target to respond about the download
            while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)>0) {
                NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: 0))
            }
            
            if !shouldContinueWithDownload {
                println("update download cancelled")
                return //somebody cancelled the download
            }
        }
        
        let downloadTask = NSURLSession.sharedSession().downloadTaskWithURL(remoteURL, completionHandler: {tempUrl, response, error in
            
            //println(tempUrl)
            //println(response)
            //println(error)
            
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
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                self.replaceFile(info: info)
            })
        })
        
        downloadTask.resume()
        
        println("started update file download")
    }
    
    func delay(#seconds: Double, completion:()->()) {
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
        
        dispatch_after(popTime, dispatch_get_main_queue()) {
            completion()
        }
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
                return //retry on next ping to remote file
            }
        }
        
        var replaceError: NSError?
        let replaceSuccess = FilePath(info.tempPath!).copyAndReplaceItemToPath(FilePath(localURL.path!), error: &replaceError)
        
        println("did replace file")
        isDownloading = false
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(info.etag!, forKey: "ETAG-\(self.remoteURL.absoluteString)")
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