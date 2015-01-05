//
//  TCBlobDownloadManager.swift
//  TCBlobDownloadSwift
//
//  Created by Thibault Charbonnier on 30/12/14.
//  Copyright (c) 2014 thibaultcha. All rights reserved.
//

import Foundation

public let TCBlobDownloadErrorDomain = "com.tcblobdownloadswift.error"
public let TCBlobDownloadErrorDescriptionKey = "TCBlobDownloadErrorDescriptionKey"
public let TCBlobDownloadErrorFailingURLKey = "TCBlobDownloadFailingURLKey"
public let TCBlobDownloadErrorHTTPStatusKey = "TCBlobDownloadErrorHTTPStatusKey"

public enum TCBlobDownloadError: Int {
    case TCBlobDownloadHTTPError = 1
}

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
        // TODO: replace with backgroundSession. Gives an unkown error for now.
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.delegate = DownloadDelegate()
        self.session = NSURLSession(configuration: config, delegate: self.delegate, delegateQueue: nil)
    }
    
    /**
        Start a download at given URL with an optional delegate
    */
    public func downloadFileAtURL(url: NSURL, toDirectory directory: NSURL?, withName name: NSString?, andDelegate delegate: TCBlobDownloadDelegate?) -> TCBlobDownload {
        let downloadTask = self.session.downloadTaskWithURL(url)
        let download = TCBlobDownload(downloadTask: downloadTask, toDirectory: directory, fileName: name, delegate: delegate)

        self.delegate.downloads[download.downloadTask.taskIdentifier] = download
        
        downloadTask.resume()
        
        return download
    }
    
    class DownloadDelegate: NSObject, NSURLSessionDownloadDelegate {
        var downloads: [Int: TCBlobDownload] = [:]
        let acceptableStatusCodes: Range<Int> = 200...299
        
        func validateResponse(response: NSHTTPURLResponse) -> Bool {
            return contains(self.acceptableStatusCodes, response.statusCode)
        }
        
        // MARK: NSURLSessionDownloadDelegate
        
        func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
            println("Resume at offset: \(fileOffset) total expected: \(expectedTotalBytes)")
        }
        
        func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
            let download = self.downloads[downloadTask.taskIdentifier]!
            let progress = totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown ? -1 : Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            
            download.delegate?.download(download, didProgress: progress, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
            
            println("Downloaded \(totalBytesWritten)/\(totalBytesExpectedToWrite) bytes. Progress: \(progress)")
        }
        
        func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
            println("did finish to DL \(downloadTask.originalRequest.URL) at URL: \(location)")
            let download = self.downloads[downloadTask.taskIdentifier]!
            var fileError: NSError?
            
            if NSFileManager.defaultManager().replaceItemAtURL(download.destinationURL, withItemAtURL: location, backupItemName: nil, options: nil, resultingItemURL: nil, error: &fileError) {
                println("Moved to \(download.destinationURL)")
            } else {
                println(fileError)
            }
        }
        
        func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError sessionError: NSError?) {
            let download = self.downloads[task.taskIdentifier]!
            var error: NSError? = sessionError
            
            // Handle possible HTTP errors
            if let response = task.response as? NSHTTPURLResponse {
                // NSURLErrorDomain errors are not supposed to be reported by this delegate
                // according to https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/URLLoadingSystem/NSURLSessionConcepts/NSURLSessionConcepts.html
                // so let's ignore them as they sometimes appear there for now. (But WTF?)
                if !validateResponse(response) && (error == nil || error!.domain == NSURLErrorDomain) {
                    error = NSError(domain: TCBlobDownloadErrorDomain,
                                      code: TCBlobDownloadError.TCBlobDownloadHTTPError.rawValue,
                                  userInfo: [TCBlobDownloadErrorDescriptionKey: "Erroneous HTTP status code: \(response.statusCode)",
                                             TCBlobDownloadErrorFailingURLKey: task.originalRequest.URL,
                                             TCBlobDownloadErrorHTTPStatusKey: response.statusCode])
                }
            }
            
            download.delegate?.download(download, didFinishWithError: error, atLocation: download.destinationURL)
            
            // Remove reference to the download
            self.downloads.removeValueForKey(task.taskIdentifier)
        }
    }
}

// MARK: TCBlobDownloadDelegate

public protocol TCBlobDownloadDelegate: class {
    func download(download: TCBlobDownload, didProgress progress: Float, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
    func download(download: TCBlobDownload, didFinishWithError: NSError?, atLocation location: NSURL)
}
