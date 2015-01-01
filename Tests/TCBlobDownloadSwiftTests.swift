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
let kHttpbinURL = NSURL(string: "http://httpbin.org")
let kValidURL = NSURL(string: "https://github.com/thibaultCha/TCBlobDownload/archive/master.zip")
let kInvalidURL = NSURL(string: "hello world")

class Httpbin {
    class func status(status: Int) -> NSURL {
        return NSURL(string: "status/\(status)", relativeToURL: kHttpbinURL)!
    }
    class func fixtureWithBytes(bytes: Int = 20) -> NSURL {
        return NSURL(string: "bytes/\(bytes)", relativeToURL: kHttpbinURL)!
    }
}

class TCBlobDownloadManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSharedInstance() {
        let manager: TCBlobDownloadManager = TCBlobDownloadManager.sharedInstance
        XCTAssertNotNil(manager, "sharedInstance is nil.")
        XCTAssert(manager === TCBlobDownloadManager.sharedInstance, "sharedInstance is not a singleton")
    }
    
    func testDownloadFileAtURLWithDelegate_call_methods() {
        let expectation = self.expectationWithDescription("should call the delegate methods")
        class DownloadHandler: NSObject, TCBlobDownloadDelegate {
            let expectation: XCTestExpectation
            var didProgressCalled = false
            var didFinishCalled = false
            init(expectation: XCTestExpectation) {
                self.expectation = expectation
            }
            func download(download: TCBlobDownload, didProgress progress: Float, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
                didProgressCalled = true
            }
            func download(download: TCBlobDownload, didFinishWithError error: NSError?) {
                didFinishCalled = true
                expectation.fulfill()
            }
        }
        
        let downloadHandler = DownloadHandler(expectation: expectation)
        
        TCBlobDownloadManager.sharedInstance.downloadFileAtURL(Httpbin.fixtureWithBytes(), withDelegate: downloadHandler)

        self.waitForExpectationsWithTimeout(kDefaultTimeout) { (error) in
            if error != nil {
                println(error)
            }
        }
        
        XCTAssertTrue(downloadHandler.didProgressCalled, "downloadDidProgress not called")
        XCTAssertTrue(downloadHandler.didFinishCalled, "downloadDidFinish not called")
    }
    
    func testDownloadFileAtURLWithDelegate_methods_parameters() {
        let expectation = self.expectationWithDescription("should call the delegate methods with the correct parameters")
        class DownloadHandler: NSObject, TCBlobDownloadDelegate {
            let expectation: XCTestExpectation
            init(expectation: XCTestExpectation) {
                self.expectation = expectation
            }
            func download(download: TCBlobDownload, didProgress progress: Float, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
                XCTAssert(10 == totalBytesWritten)
                XCTAssert(10 == totalBytesExpectedToWrite)
                XCTAssert(1.0 == progress)
            }
            func download(download: TCBlobDownload, didFinishWithError error: NSError?) {
                expectation.fulfill()
            }
        }
        
        let downloadHandler = DownloadHandler(expectation: expectation)
        
        TCBlobDownloadManager.sharedInstance.downloadFileAtURL(Httpbin.fixtureWithBytes(bytes: 10), withDelegate: downloadHandler)
        
        self.waitForExpectationsWithTimeout(kDefaultTimeout) { (error) in
            if error != nil {
                println(error)
            }
        }
    }
    
    func testDownloadFileAtURLWithDelegate_invalid_response() {
        let expectation = self.expectationWithDescription("should report any HTTP error")
        class DownloadHandler: NSObject, TCBlobDownloadDelegate {
            let expectation: XCTestExpectation
            init(expectation: XCTestExpectation) {
                self.expectation = expectation
            }
            func download(download: TCBlobDownload, didProgress progress: Float, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {

            }
            func download(download: TCBlobDownload, didFinishWithError error: NSError?) {
                XCTAssertNotNil(error, "No error returned for an erroneous HTTP status code")
                XCTAssertNotNil(error?.userInfo?[NSLocalizedDescriptionKey], "Error userInfo is missing localized description")
                XCTAssert(error?.userInfo?["status"] as NSValue == 404, "Error userInfo is missing status")
                XCTAssert(error?.userInfo?[NSURLErrorKey] as NSString == Httpbin.status(404).absoluteString!, "Error userInfo has wrong NSURLErrorKey value")
                expectation.fulfill()
            }
        }
        
        let downloadHandler = DownloadHandler(expectation: expectation)

        TCBlobDownloadManager.sharedInstance.downloadFileAtURL(Httpbin.status(404), withDelegate: downloadHandler)
        
        self.waitForExpectationsWithTimeout(kDefaultTimeout) { (error) in
            if error != nil {
                println(error)
            }
        }
    }
}
