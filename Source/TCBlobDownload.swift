//
//  TCBlobDownload.swift
//  TCBlobDownloadSwift
//
//  Created by Thibault Charbonnier on 30/12/14.
//  Copyright (c) 2014 thibaultcha. All rights reserved.
//

import Foundation

public class TCBlobDownload {
    /// The underlying download task.
    public let downloadTask: NSURLSessionDownloadTask

    /// An optional delegate to get notified of events.
    weak var delegate: TCBlobDownloadDelegate?

    /// An optional file name set by the user.
    private let preferedFileName: String?

    /// An optional destination path for the file. If nil, the file will be downloaded in the current user temporary directory.
    private let directory: NSURL?

    /// Will contain an error if the downloaded file couldn't be moved to its final destination.
    var error: NSError?

    /// Current progress of the download, a value between 0 and 1. 0 means the download hasn't started and 1 means the download is completed.
    public var progress: Float = 0

    /// If the moving of the file after downloading was successful, will contain the `NSURL` pointing to the final file.
    public var resultingURL: NSURL?

    /// A computed property to get the filename of the downloaded file.
    public var fileName: String? {
        return self.preferedFileName ?? self.downloadTask.response?.suggestedFilename
    }

    /// A computed destination URL depending on the `destinationPath`, `fileName`, and `suggestedFileName` from the underlying `NSURLResponse`.
    public var destinationURL: NSURL {
        let destinationPath = self.directory ?? NSURL(fileURLWithPath: NSTemporaryDirectory())

        return NSURL(string: self.fileName!, relativeToURL: destinationPath!)!.URLByStandardizingPath!
    }

    /**
        Initialize a new download assuming the `NSURLSessionDownloadTask` was already created.
    
        :param: downloadTask The underlying download task for this download.
        :param: directory The directory where to move the downloaded file once completed.
        :param: fileName The preferred file name once the download is completed.
        :param: delegate An optional delegate for this download.
    */
    init(downloadTask: NSURLSessionDownloadTask, toDirectory directory: NSURL?, fileName: String?, delegate: TCBlobDownloadDelegate?) {
        self.downloadTask = downloadTask
        self.directory = directory
        self.preferedFileName = fileName
        self.delegate = delegate
    }

    /**
        Cancel a download. The download cannot be resumed after calling this method.
    
        :see: `NSURLSessionDownloadTask -cancel`
    */
    public func cancel() {
        self.downloadTask.cancel()
    }

    /**
        Suspend a download. The download can be resumed after calling this method.
    
        :see: `TCBlobDownload -resume`
        :see: `NSURLSessionDownloadTask -suspend`
    */
    public func suspend() {
        self.downloadTask.suspend()
    }

    /**
        Resume a previously suspended download. Can also start a download if not already downloading.
    
        :see: `NSURLSessionDownloadTask -resume`
    */
    public func resume() {
        self.downloadTask.resume()
    }

    /**
        Cancel a download and produce resume data. If stored, this data can allow resuming the download at its previous state.

        :see: `TCBlobDownloadManager -downloadFileWithResumeData`
        :see: `NSURLSessionDownloadTask -cancelByProducingResumeData`

        :param: completionHandler A completion handler that is called when the download has been successfully canceled. If the download is resumable, the completion handler is provided with a resumeData object.
    */
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
