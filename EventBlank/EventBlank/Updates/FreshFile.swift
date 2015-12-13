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

class FreshFile: NSObject, NSURLSessionDownloadDelegate {

    //MARK: - FreshFile properties
    var remoteURL: NSURL!
    var localURL: NSURL!
    
    var refreshRate: Double = 60.0
    var networkRetryInterval = 20.0
    
    let manager = NSFileManager.defaultManager()
    
    init(localURL: NSURL, remoteURL: NSURL) {
        self.localURL = localURL
        self.remoteURL = remoteURL
    }
    
    //MARK: - actions
    typealias BoolClosure = (Bool)->Void
    
    var willDownloadFileMap = OrderedMap<String, (FreshInfo, BoolClosure)->Void>()
    var willReplaceFileMap = OrderedMap<String, (FreshInfo)->Bool>()
    var didReplaceFileMap = OrderedMap<String, BoolClosure>()
    
    static private var actionCounter = 0
    
    func addAction(willDownloadFile willDownloadFile: (FreshInfo, BoolClosure)->Void, withKey: String?) {
        willDownloadFileMap[withKey ?? "default-\(++self.dynamicType.actionCounter)"] = willDownloadFile
    }
    
    func addAction(willReplaceFile willReplaceFile: (FreshInfo)->Bool, withKey: String?) {
        willReplaceFileMap[withKey ?? "default-\(++self.dynamicType.actionCounter)"] = willReplaceFile
    }
    
    func addAction(didReplaceFile didReplaceFile: BoolClosure, withKey: String?) {
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
            print("newer version: \(fileInfo)")
          
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
        
        let request = NSMutableURLRequest(URL: remoteURL, cachePolicy: NSURLRequestCachePolicy.ReloadRevalidatingCacheData, timeoutInterval: 60.0)
        request.HTTPMethod = "HEAD"
        
        let semaphore = dispatch_semaphore_create(0)
        
        let dataTask = NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration()).dataTaskWithRequest(request, completionHandler: {data, response, error in
            //print(data)
            //print(response)
            //print(error)
            
            if error != nil {
                
                //print("could not HEAD file: \(request.URL). Error: \(error.localizedDescription)")
                
                //retry
                self.delay(seconds: self.networkRetryInterval, completion: {
                    //print("retry network call")
                    self.refresh()
                })
                
            } else if let response = response as? NSHTTPURLResponse,
                let newEtag = response.allHeaderFields["Etag"] as? String {
                
                let defaults = NSUserDefaults.standardUserDefaults()
                let currentEtag = defaults.valueForKey("ETAG-\(self.remoteURL.absoluteString)") as? String
                    
                print("compare local \(currentEtag) to \(newEtag)")
                print("compare initial \(initialEtag) to \(newEtag)")
                
                if newEtag  != currentEtag && newEtag != initialEtag {
                    //there is a newer file!
                    print("remote file is newer")
                    
                    //TODO: CHECK IF it's initial fetching of etag
                    fileInfo = FreshInfo()
                    fileInfo!.etag = newEtag
                    
                    if let contentLength = response.allHeaderFields["Content-Length"] as? String {
                        fileInfo!.contentLength = (contentLength as NSString).doubleValue
                        print("about to download \(fileInfo!.contentLength) bytes")
                    }
                    
                } else {
                    //print("event file is up to date")
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
    private var downloadSession: NSURLSession?
    private var downloadInfo: FreshInfo?
    
    var downloadHandlerWithProgress: ((Double) -> Void)?
    
    func downloadFile(info info: FreshInfo) {
        
        print("will download file")
        
        if downloadSession != nil {
            return
        }
        
        let semaphore = dispatch_semaphore_create(0)
        var shouldContinueWithDownload = true
        
        //ask all interested parties if they allow the download
        for (_, handler) in self.willDownloadFileMap {
            
            handler(info, {result in
                shouldContinueWithDownload = shouldContinueWithDownload && result
                dispatch_semaphore_signal(semaphore)
            })
            
            //wait for the target to respond about the download
            while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)>0) {
                NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: 0))
            }
            
            if !shouldContinueWithDownload {
                print("update download cancelled")
                return //somebody cancelled the download
            }
        }
        
        downloadSession = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: self,
            delegateQueue: nil)
        downloadInfo = info
        
        downloadHandlerWithProgress?(0.0)
        let uniqueURLString = remoteURL.absoluteString + ((remoteURL.query != nil) ? "" : "?") + "&rand=\(arc4random_uniform(arc4random()))"
        let uniqueURL = NSURL(string: uniqueURLString)!
        
        downloadSession!.downloadTaskWithURL(uniqueURL).resume()

        print("started update file download: \(uniqueURL.absoluteString)")
    }
    
    func delay(seconds seconds: Double, completion:()->()) {
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
        
        dispatch_after(popTime, dispatch_get_main_queue()) {
            completion()
        }
    }
    
    func replaceFile(info info: FreshInfo) {
        //try to replace existing file
        print("will replace file")
        
        //check if temp file is still there
        if let tempPath = info.tempPath where manager.fileExistsAtPath(tempPath) == false {
            print("temp file already exists, exiting?")
            return //all done
        }
        
        //check if allowed to replace file
        for (_, handler) in self.willReplaceFileMap {
            if handler(info) == false {
                print("not allowed to replace file right now")
                return //retry on next ping to remote file
            }
        }
        
        var replaceSuccess = false
        
        do {
            try FilePath(info.tempPath!).copyAndReplaceItemToPath(FilePath(localURL.path!))
            try NSFileManager().removeItemAtPath(info.tempPath!)
            replaceSuccess = true
            print("did replace file")
        } catch {
            print("could not replace file")
        }
        
        isDownloading = false
        
        self.delay(seconds: 0.1, completion: {
            
            let defaults = NSUserDefaults.standardUserDefaults()
            print("store etag \(info.etag!) in ETAG-\(self.remoteURL.absoluteString)")
            defaults.setValue(info.etag!, forKey: "ETAG-\(self.remoteURL.absoluteString)")
            defaults.synchronize()

            for (_, handler) in self.didReplaceFileMap {
                handler(replaceSuccess)
            }
        })
    }
    
    override var description: String {
        return "FreshFile: \(localURL.absoluteString)\n  willReplaceFileMap: \(willReplaceFileMap)\n\n  didReplaceFile: \(didReplaceFileMap)\n\n"
    }
    
    //MARK: - download session methods
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        //copy the downloaded file to a temp location
        downloadInfo!.tempPath = self.localURL.path!.stringByAppendingString(".pending")
        
        do {
            try FilePath(location.path!).copyAndReplaceItemToPath(FilePath(downloadInfo!.tempPath!))
        } catch let error as NSError {
            //failed to create a temp copy
            self.isDownloading = false
            print("failed to copy temp file: \(error.localizedDescription)")
        }
        
        self.downloadSession?.invalidateAndCancel()
        self.downloadSession = nil
        
        mainQueue({
            if self.isDownloading {
                self.replaceFile(info: self.downloadInfo!)
                self.downloadInfo = nil
            }
        })
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        downloadHandlerWithProgress?(Double(totalBytesWritten) / Double(totalBytesExpectedToWrite))
    }
    
}