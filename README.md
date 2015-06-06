# TCBlobDownloadSwift

Powerful file downloads for iOS 7+ with [NSURLSession][nsurlsession-url] in Swift.

TCBlobDownloadSwift makes it easy to quickly download one or several large file(s) from your backend or the Internet right into your app. Give it an URL, a directory (or not, it can also download into the user's tmp folder), a name (or not, it can also give your file a default name), and it will take care of everything.

See the [Usage](#usage) section for examples.

### Features

- [x] File downloads with `NSURLSession` (including background downloads/pause/resume)
- [x] File management (download directory + customizable filename)
- [x] Download tasks configuration (cookies, timeout, number of concurrent connections...)
- [x] Progression/Completion Protocol (delegate style)
- [x] Progression/Completion Closures
- [x] Complete example project with concurrent file downloading

### Requirements

- iOS 7.0+ / Mac OS X 10.9+

### Installation

##### Cocoapods

Add the following to your Podfile:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'TCBlobDownloadSwift', '~> 0.1.0'
```

And run:

```
$ pod install
```

[Here][cocoapod-swift-help] is a helpful article about setting up your project to use Cocoapods with Swift.

##### Import as an embedded framework

- Drag and drop `TCBlobDownloadSwift.xcodeproj` from the Finder to your opened project's file navigator.
- Project's Target -> Build Phases -> **Target Dependencies** -> add `TCBlobDownloadSwift.framework`.
- Click on the + button at the top left of the panel and select "New Copy Files Phase". Set the "Destination" to "Frameworks", and add `TCBlobDownloadSwift.framework`.

##### Import source files

For iOS 7 and other targets which do not support embedded frameworks, copy the source files (`Source/*.swift}`) into your project.

### Usage

Before checking the iOS example project, here is how TCBlobDownloadSwift works in a few lines of code:

##### Closures

Coming!

##### Delegate

```swift
import TCBlobDownloadSwift

// Here is a simple delegate implementing TCBlobDownloadDelegate.
class DownloadHandler: NSObject, TCBlobDownloadDelegate {
  init() {}

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

[nsurlsession-url]: https://developer.apple.com/library/ios/documentation/Foundation/Reference/NSURLSession_class/

[cocoapods-url]: http://cocoapods.org/

[cocoapod-swift-help]: http://swiftalicio.us/2014/11/using-cocoapods-from-swift/
