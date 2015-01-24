//
//  TCBlobDownload.swift
//  TCBlobDownloadSwift
//
//  Created by Thibault Charbonnier on 30/12/14.
//  Copyright (c) 2014 thibaultcha. All rights reserved.
//

import Foundation

public class TCBlobDownload {
    // The underlaying session download task
    public let downloadTask: NSURLSessionDownloadTask

    // An optional delegate to get notified of events
    weak var delegate: TCBlobDownloadDelegate?

    // An optional file name set by the user.
    private let preferedFileName: String?

    // An optional destination path for the file. If nil, the file will be downloaded in the current user temporary directory
    private let directory: NSURL?

    // If the downloaded file couldn't be moved to its final destination, will contain the error
    var error: NSError?

    // Current pgoress of the download, a value between 0 and 1
    public var progress: Float = 0

    // If the final copy of the file was successful, will contain the URL to the final file
    public var resultingURL: NSURL?

    // A computed property to get the filename of the downloaded file
    public var fileName: String? {
        return self.preferedFileName ?? self.downloadTask.response?.suggestedFilename
    }

    // A computed destinationURL depending on the destinationPath, fileName, and suggestedFileName from the underlying NSURLResponse
    public var destinationURL: NSURL {
        let destinationPath = self.directory ?? NSURL(fileURLWithPath: NSTemporaryDirectory())

        return NSURL(string: self.fileName!, relativeToURL: destinationPath!)!.URLByStandardizingPath!
    }

    // Initialize a new download assuming the NSURLSessionDownloadTask is already created
    init(downloadTask: NSURLSessionDownloadTask, toDirectory directory: NSURL?, fileName: String?, delegate: TCBlobDownloadDelegate?) {
        self.downloadTask = downloadTask
        self.directory = directory
        self.preferedFileName = fileName
        self.delegate = delegate
    }

    public func cancel() {
        self.downloadTask.cancel()
    }

    public func suspend() {
        self.downloadTask.suspend()
    }

    public func resume() {
        self.downloadTask.resume()
    }

    public func cancelWithResumeData(completionHandler: (NSData!) -> Void) {
        self.downloadTask.cancelByProducingResumeData(completionHandler)
    }

    // TODO: closures
    // TODO: remaining time
}

// MARK: - Printable

extension TCBlobDownload: Printable {
    public var description: String {
        var parts: [String] = []
        var state: String
        
        switch self.downloadTask.state {
            case .Running: state = "running"
            case .Completed: state = "completed"
            case .Canceling: state = "canceling"
            case .Suspended: state = "suspended"
        }
        
        parts.append("TCBlobDownload")
        parts.append("URL: \(self.downloadTask.originalRequest.URL)")
        parts.append("Download task state: \(state)")
        parts.append("destinationPath: \(self.directory)")
        parts.append("fileName: \(self.fileName)")
        
        return join(" | ", parts)
    }
}
