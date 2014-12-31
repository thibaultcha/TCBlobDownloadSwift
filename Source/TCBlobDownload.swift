//
//  TCBlobDownload.swift
//  TCBlobDownloadSwift
//
//  Created by Thibault Charbonnier on 30/12/14.
//  Copyright (c) 2014 thibaultcha. All rights reserved.
//

import Foundation

public class TCBlobDownload {
    let fileName: String?
    let destinationPath: String
    let downloadTask: NSURLSessionDownloadTask
    let delegate: TCBlobDownloadDelegate?
    
    init(downloadTask: NSURLSessionDownloadTask, fileName: String?, destinationPath: String, delegate: TCBlobDownloadDelegate?) {
        self.fileName = fileName
        self.destinationPath = destinationPath
        self.downloadTask = downloadTask
        self.delegate = delegate
    }
    
    // TODO: closures
    // TODO: cancel, resume, suspend, state
    // TODO: if no filename, get NSURLResponse suggestedFilename
}