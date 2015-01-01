//
//  TCBlobDownloadManager.swift
//  TCBlobDownloadSwift
//
//  Created by Thibault Charbonnier on 30/12/14.
//  Copyright (c) 2014 thibaultcha. All rights reserved.
//

import Foundation

public let kTCBlobDownloadErrorDomain = "com.tcblobwodwnloadswift.error"

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
    public func downloadFileAtURL(url: NSURL, withDelegate delegate: TCBlobDownloadDelegate?) -> TCBlobDownload {
        let downloadTask = self.session.downloadTaskWithURL(url)
        let download = TCBlobDownload(downloadTask: downloadTask, fileName: nil, destinationPath: "", delegate: delegate)

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
            let progress: Float = totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown ? -1 : Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            
            download.delegate?.download(download, didProgress: progress, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
            
            println("Downloaded \(totalBytesWritten)/\(totalBytesExpectedToWrite) bytes. Progress: \(progress)")
        }
        
        func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
            println("did finish at URL: \(location)")
        }
        
        func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError sessionError: NSError?) {
            let download = self.downloads[task.taskIdentifier]!
            var error: NSError? = sessionError
            
            // Handle possible HTTP errors
            if let response = task.response as? NSHTTPURLResponse {
                if !validateResponse(response) && error == nil {
                    error = NSError(domain: kTCBlobDownloadErrorDomain,
                                      code: TCBlobDownloadError.TCBlobDownloadHTTPError.rawValue,
                                  userInfo: [NSLocalizedDescriptionKey: "Erroneous HTTP status code: \(response.statusCode)",
                                             NSURLErrorKey: "\(download.downloadTask.originalRequest.URL.absoluteString!)",
                                             "status": response.statusCode])
                }
            }
            
            download.delegate?.download(download, didFinishWithError: error)
            
            // Remove reference to the download
            self.downloads.removeValueForKey(task.taskIdentifier)
        }
    }
}

// MARK: TCBlobDownloadDelegate

public protocol TCBlobDownloadDelegate {
    func download(download: TCBlobDownload, didProgress progress: Float, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
    func download(download: TCBlobDownload, didFinishWithError: NSError?)
}
