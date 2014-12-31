//
//  TCBlobDownloadManager.swift
//  TCBlobDownloadSwift
//
//  Created by Thibault Charbonnier on 30/12/14.
//  Copyright (c) 2014 thibaultcha. All rights reserved.
//

import Foundation

public class TCBlobDownloadManager {
    // The underlying NSURLSession
    private let session: NSURLSession
    
    // Instance of the underlying class implementing NSURLSessionDownloadDelegate
    private let delegate: DownloadDelegate
    
    /**
        A shared instance of TCBlobDownloadManager
    */
    public class var sharedInstance: TCBlobDownloadManager {
        struct Singleton {
            static let instance = TCBlobDownloadManager()
        }
        
        return Singleton.instance
    }
    
    init() {
        // TODO replace with backgroundSession
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.delegate = DownloadDelegate()
        self.session = NSURLSession(configuration: config, delegate: self.delegate, delegateQueue: nil)
    }
    
    public func downloadFileAtURL(url: NSURL?, withDelegate delegate: TCBlobDownloadDelegate?) -> TCBlobDownload {
        let downloadTask = self.session.downloadTaskWithURL(url!)
        let download = TCBlobDownload(downloadTask: downloadTask, fileName: url!.absoluteString!, destinationPath: "", delegate: delegate)

        self.delegate.downloads[download.downloadTask.hash] = download
        
        downloadTask.resume()
        
        return download
    }
    
    class DownloadDelegate: NSObject, NSURLSessionDownloadDelegate {
        var downloads: [Int: TCBlobDownload] = [:]
        
        // MARK: NSURLSessionDownloadDelegate
        
        func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
            println("Resume at offset: \(fileOffset) total expected: \(expectedTotalBytes)")
        }
        
        func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
            println("did write data")
        }
        
        func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
            println("did finish at URL: \(location)")
        }
        
        func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
            let finishedDL = self.downloads[task.hash]
            finishedDL?.delegate?.download(finishedDL!, didFinishWithError: error)
            self.downloads.removeValueForKey(task.hash)
        }
    }
}

public protocol TCBlobDownloadDelegate {
    func download(download: TCBlobDownload, didFinishWithError: NSError?) -> Void
}
