# TCBlobDownloadSwift

> :heartbeat: This library is currently receiving a lot of love.
>
> (understand: under active development)

File downloads for iOS 7+ with [NSURLSession][nsurlsession-url] in Swift.

TCBlobDownloadSwift is not yet completed in terms of features but can already be used in a production application.

### Features
- [x] File downloads with iOS 7's `NSURLSession` (including pause/resume)
- [x] File management (download directory + customizable filename)
- [x] Full customization of your `NSURLSessionTasks` (maximum number of concurrent connections)
- [x] Progression/Completion delegate methods
- [x] Complete example project with multiple downloads

### Requirements
- iOS 7.0+ / Mac OS X 10.9+

### Usage

Before checking the iOS example project, here is how TCBlobDownloadSwift works in a few lines of code:

```swift
import TCBlobDownloadSwift

// Defining a simple delegate
class DownloadHandler: NSObject, TCBlobDownloadDelegate {
    init() {

    }
    func download(download: TCBlobDownload, didProgress progress: Float, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        println("\(progress*100)% downloaded")
    }
    func download(download: TCBlobDownload, didFinishWithError error: NSError?, atLocation location: NSURL?) {
        println("file downloaded at \(location)")
    }
}

let fileURL = NSURL(string: "http://some.huge/file.mp4")
let download = TCBlobDownloadManager.sharedInstance
                                    .downloadFileAtURL(fileURL!, toDirectory: nil, withName: nil, andDelegate: DownloadHandler())
```

### Roadmap
- [ ] Documentation set
- [ ] Full background download example
- [ ] File upload
- [ ] Closures (instead of protocol)

[nsurlsession-url]: https://developer.apple.com/library/ios/documentation/Foundation/Reference/NSURLSession_class/