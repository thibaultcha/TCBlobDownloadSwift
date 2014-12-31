//
//  TCBlobDownloadSwiftTests.swift
//  TCBlobDownloadSwiftTests
//
//  Created by Thibault Charbonnier on 30/12/14.
//  Copyright (c) 2014 thibaultcha. All rights reserved.
//

import XCTest
import TCBlobDownloadSwift

let kDefaultTimeout: NSTimeInterval = 2.0
let kValidURL: NSURL = NSURL(string: "http://httpbin.org/stream-bytes/")!

class DownloadHandler: NSObject, TCBlobDownloadDelegate {
    let expectation: XCTestExpectation
    var finishAssertion: ()?
    
    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }
    
    func download(download: TCBlobDownload, didFinishWithError: NSError?) {
        expectation.fulfill()
    }
}

class TCBlobDownloadSwiftTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSharedInstance() {
        let manager: TCBlobDownloadManager = TCBlobDownloadManager.sharedInstance
        let manager2 = TCBlobDownloadManager.sharedInstance
        XCTAssertNotNil(manager, "sharedInstance is nil.")
        XCTAssertTrue(manager === manager2, "sharedInstance is not a singleton")
    }
    
    func testDownloadFileAtURL() {
        var expectation = self.expectationWithDescription("should download a file????")
        let handler = DownloadHandler(expectation: expectation)

        TCBlobDownloadManager.sharedInstance.downloadFileAtURL(kValidURL, withDelegate: handler)

        self.waitForExpectationsWithTimeout(kDefaultTimeout, handler: { (error: NSError!) -> Void in
            if (error != nil) {
                println(error)
            }
        })
    }
    
}
