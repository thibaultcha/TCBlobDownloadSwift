//
//  TCBlobDownloadSwiftTests.swift
//  TCBlobDownloadSwiftTests
//
//  Created by Thibault Charbonnier on 30/12/14.
//  Copyright (c) 2014 thibaultcha. All rights reserved.
//

import XCTest
import TCBlobDownloadSwift

let kTestsDirectory = NSURL(string: "com.tcblobdownload.tests/", relativeToURL: NSURL(fileURLWithPath: NSTemporaryDirectory()))!
let kDefaultTimeout: NSTimeInterval = 2.0
let kHttpbinURL = NSURL(string: "http://httpbin.org")!
let kValidURL = NSURL(string: "https://github.com/thibaultCha/TCBlobDownload/archive/master.zip")!
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
        
        var error: NSError?
        do {
            try NSFileManager.defaultManager().createDirectoryAtURL(kTestsDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch let error1 as NSError {
            error = error1
        }
        XCTAssertNil(error, "Failed to create tests directory: \(error)")
    }
    
    override func tearDown() {
        var error: NSError?
        do {
            try NSFileManager.defaultManager().removeItemAtURL(kTestsDirectory)
        } catch let error1 as NSError {
            error = error1
            print("Error while removing tests directory: \(error)")
        }
        
        super.tearDown()
    }

    func waitForExpectationsWithDefaultHandler(timeout: NSTimeInterval = 10, handler: XCWaitCompletionHandler! = { if $0 != nil {print($0)} }) {
        self.waitForExpectationsWithTimeout(timeout, handler: handler)
    }

    func testSharedInstance() {
        let manager: TCBlobDownloadManager = TCBlobDownloadManager.sharedInstance
        XCTAssertNotNil(manager, "sharedInstance is nil.")
        XCTAssert(manager === TCBlobDownloadManager.sharedInstance, "sharedInstance is not a singleton")
    }
    
    func testDownloadFileAtURLWithDelegate_to_directory() {
        let expectation = self.expectationWithDescription("should download the file at given directory")
        let expectedResultingURL = NSURL(string: "first_test", relativeToURL: kTestsDirectory)!
        
        class DownloadHandler: NSObject, TCBlobDownloadDelegate {
            let expectation: XCTestExpectation
            init(expectation: XCTestExpectation) {
                self.expectation = expectation
            }
            func download(download: TCBlobDownload, didProgress progress: Float, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {}
            func download(download: TCBlobDownload, didFinishWithError error: NSError?, atLocation location: NSURL?) {
                XCTAssertNil(error, "Download failed with error.")
                XCTAssertNotNil(location, "Successful download didn't send the location parameter")
                // Xcode error
                //XCTAssertEqual(expectedResultingURL.absoluteString!, location?.absoluteString!, "Location parameter doesn't match the expected URL")
                expectation.fulfill()
            }
        }
        
        let downloadHandler = DownloadHandler(expectation: expectation)
        
        TCBlobDownloadManager.sharedInstance.downloadFileAtURL(Httpbin.fixtureWithBytes(), toDirectory: kTestsDirectory, withName: "first_test", andDelegate: downloadHandler)
        
        self.waitForExpectationsWithDefaultHandler()
        
        let exists = NSFileManager.defaultManager().fileExistsAtPath(expectedResultingURL.path!)
        XCTAssertTrue(exists, "File not downloaded at given path")
    }

    func testDownloadFileAtURLWithClosures_to_directory() {
        let expectation = self.expectationWithDescription("should download the file at given directory")
        let expectedResultingURL = NSURL(string: "first_test", relativeToURL: kTestsDirectory)!

        TCBlobDownloadManager.sharedInstance.downloadFileAtURL(Httpbin.fixtureWithBytes(), toDirectory: kTestsDirectory, withName: "first_test", progression: nil) { (error, location) -> Void in
            XCTAssertNil(error, "Download failed with error.")
            XCTAssertNotNil(location, "Successful download didn't send the location parameter")
            expectation.fulfill()
        }

        self.waitForExpectationsWithDefaultHandler()

        let exists = NSFileManager.defaultManager().fileExistsAtPath(expectedResultingURL.path!)
        XCTAssertTrue(exists, "File not downloaded at given path")
    }
    
    func testDownloadFileAtURLWithDelegate_call_methods() {
        let expectation = self.expectationWithDescription("should call the delegate methods")
        class DownloadHandler: NSObject, TCBlobDownloadDelegate {
            let expectation: XCTestExpectation
            var didProgressCalled = false
            init(expectation: XCTestExpectation) {
                self.expectation = expectation
            }
            func download(download: TCBlobDownload, didProgress progress: Float, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
                didProgressCalled = true
            }
            func download(download: TCBlobDownload, didFinishWithError error: NSError?, atLocation location: NSURL?) {
                expectation.fulfill()
            }
        }
        
        let downloadHandler = DownloadHandler(expectation: expectation)
        
        TCBlobDownloadManager.sharedInstance.downloadFileAtURL(Httpbin.fixtureWithBytes(), toDirectory: kTestsDirectory, withName: nil, andDelegate: downloadHandler)

        self.waitForExpectationsWithDefaultHandler()
        
        XCTAssertTrue(downloadHandler.didProgressCalled, "downloadDidProgress not called")
    }

    func testDownloadFileAtURLWithClosures_call_methods() {
        let expectation = self.expectationWithDescription("should call the completion block")
        var didCallProgress = false

        TCBlobDownloadManager.sharedInstance.downloadFileAtURL(Httpbin.fixtureWithBytes(), toDirectory: kTestsDirectory, withName: nil, progression: { (progress, totalBytesWritten, totalBytesExpectedToWrite) -> Void in
            didCallProgress = true
        }) { (error, location) -> Void in
            expectation.fulfill()
        }

        self.waitForExpectationsWithDefaultHandler()

        XCTAssertTrue(didCallProgress, "progression closure not called")
    }
    
    func testDownloadFileAtURLWithDelegate_methods_parameters() {
        let expectation = self.expectationWithDescription("should call the delegate methods with the correct parameters")
        class DownloadHandler: NSObject, TCBlobDownloadDelegate {
            let expectation: XCTestExpectation
            var didProgressCalled = false
            init(expectation: XCTestExpectation) {
                self.expectation = expectation
            }
            func download(download: TCBlobDownload, didProgress progress: Float, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
                XCTAssert(10 == totalBytesWritten)
                XCTAssert(10 == totalBytesExpectedToWrite)
                XCTAssert(1.0 == progress)
            }
            func download(download: TCBlobDownload, didFinishWithError error: NSError?, atLocation location: NSURL?) {
                expectation.fulfill()
            }
        }
        
        let downloadHandler = DownloadHandler(expectation: expectation)
        
        TCBlobDownloadManager.sharedInstance.downloadFileAtURL(Httpbin.fixtureWithBytes(bytes: 10), toDirectory: kTestsDirectory, withName: nil, andDelegate: downloadHandler)
        
        self.waitForExpectationsWithDefaultHandler()
    }

    func testDownloadFileAtURLWithClosures_parameters() {
        let expectation = self.expectationWithDescription("should call the closures with the correct parameters")

        TCBlobDownloadManager.sharedInstance.downloadFileAtURL(Httpbin.fixtureWithBytes(bytes: 10), toDirectory: kTestsDirectory, withName: nil, progression: { (progress, totalBytesWritten, totalBytesExpectedToWrite) -> Void in
            XCTAssert(10 == totalBytesWritten)
            XCTAssert(10 == totalBytesExpectedToWrite)
            XCTAssert(1.0 == progress)
        }) { (error, location) -> Void in
            expectation.fulfill()
        }

        self.waitForExpectationsWithDefaultHandler()
    }

    func testDownloadFileAtURLWithDelegate_methods_on_main_thread() {
        let expectation = self.expectationWithDescription("should call the delegate methods on the main thread")
        class DownloadHandler: NSObject, TCBlobDownloadDelegate {
            let expectation: XCTestExpectation
            var didProgressCalled = false
            init(expectation: XCTestExpectation) {
                self.expectation = expectation
            }
            func download(download: TCBlobDownload, didProgress progress: Float, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
                XCTAssert(NSThread.isMainThread(), "download:didProgress: not called on main thread")
            }
            func download(download: TCBlobDownload, didFinishWithError error: NSError?, atLocation location: NSURL?) {
                XCTAssert(NSThread.isMainThread(), "didFinishWithError: not called on main thread")
                expectation.fulfill()
            }
        }

        let downloadHandler = DownloadHandler(expectation: expectation)

        TCBlobDownloadManager.sharedInstance.downloadFileAtURL(Httpbin.fixtureWithBytes(bytes: 10), toDirectory: kTestsDirectory, withName: nil, andDelegate: downloadHandler)

        self.waitForExpectationsWithDefaultHandler()
    }

    func testDownloadFileAtURLWithClosures_on_main_thread() {
        let expectation = self.expectationWithDescription("should call the closures on the main thread")

        TCBlobDownloadManager.sharedInstance.downloadFileAtURL(Httpbin.fixtureWithBytes(bytes: 10), toDirectory: kTestsDirectory, withName: nil, progression: { (progress, totalBytesWritten, totalBytesExpectedToWrite) -> Void in
            XCTAssert(NSThread.isMainThread(), "progression closure not called on main thread")
        }) { (error, location) -> Void in
            XCTAssert(NSThread.isMainThread(), "completion closure not called on main thread")
            expectation.fulfill()
        }

        self.waitForExpectationsWithDefaultHandler()
    }

    func testDownloadFileAtURLWithDelegate_invalid_response() {
        let expectation = self.expectationWithDescription("should report any HTTP error")
        class DownloadHandler: NSObject, TCBlobDownloadDelegate {
            let expectation: XCTestExpectation
            init(expectation: XCTestExpectation) {
                self.expectation = expectation
            }
            func download(download: TCBlobDownload, didProgress progress: Float, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {}
            func download(download: TCBlobDownload, didFinishWithError error: NSError?, atLocation location: NSURL?) {
                XCTAssertNotNil(error, "No error returned for an erroneous HTTP status code")
                XCTAssertNotNil(error?.userInfo?[kTCBlobDownloadErrorDescriptionKey], "Error userInfo is missing localized description")
                XCTAssert(error?.userInfo?[kTCBlobDownloadErrorHTTPStatusKey] as? NSValue == 404, "Error userInfo is missing status")
                
                if let requestURL = error?.userInfo?[kTCBlobDownloadErrorFailingURLKey] as? NSURL {
                    XCTAssertEqual(Httpbin.status(404).absoluteString!, requestURL.absoluteString!, "Error userInfo has wrong TCBlobDownloadErrorFailingURLKey value")
                } else {
                    XCTFail("Error userInfo TCBlobDownloadErrorFailingURLKey is not an NSURL")
                }

                expectation.fulfill()
            }
        }
        
        let downloadHandler = DownloadHandler(expectation: expectation)

        TCBlobDownloadManager.sharedInstance.downloadFileAtURL(Httpbin.status(404), toDirectory: kTestsDirectory, withName: nil, andDelegate: downloadHandler)
        
        self.waitForExpectationsWithDefaultHandler()
    }

    func testDownloadFileAtURLWithDelegate_return_download_instance() {
        let download: TCBlobDownload = TCBlobDownloadManager.sharedInstance.downloadFileAtURL(Httpbin.fixtureWithBytes(), toDirectory: kTestsDirectory, withName: nil, andDelegate: nil)

        XCTAssertNotNil(download, "downloadFileAtURL: did not return a download instance")
    }

    func testDownloadFileAtURLWithDelegate_start_immediatly() {
        // Immediate running
        let immediateDownload = TCBlobDownloadManager.sharedInstance.downloadFileAtURL(Httpbin.fixtureWithBytes(), toDirectory: kTestsDirectory, withName: nil, andDelegate: nil)
        XCTAssert(immediateDownload.downloadTask.state == NSURLSessionTaskState.Running)

        // Non immediate running
        let manager = TCBlobDownloadManager()
        manager.startImmediatly = false

        let download = manager.downloadFileAtURL(Httpbin.fixtureWithBytes(), toDirectory: kTestsDirectory, withName: nil, andDelegate: nil)
        XCTAssert(download.downloadTask.state == NSURLSessionTaskState.Suspended)
    }
}
