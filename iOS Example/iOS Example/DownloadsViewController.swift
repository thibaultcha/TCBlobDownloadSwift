//
//  DownloadsViewController.swift
//  iOS Example
//
//  Created by Thibault Charbonnier on 12/01/15.
//  Copyright (c) 2015 Thibault Charbonnier. All rights reserved.
//

import Foundation
import UIKit
import TCBlobDownloadSwift

private let kDownloadCellidentifier = "downloadCellIdentifier"

class DownloadsViewController: UIViewController {

    let manager = TCBlobDownloadManager.sharedInstance

    // Keep track of the current (and probably past soon) downloads
    // This is the tableview's data source
    var downloads = [TCBlobDownload]()

    @IBOutlet weak var downloadsTableView: UITableView!

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toAddDownload" {
            let destinationNC = segue.destinationViewController as! UINavigationController
            let destinationVC = destinationNC.topViewController as! AddDownloadViewController
            destinationVC.delegate = self
        }
    }

    func addDownloadWithURL(url: NSURL?, name: String?) {
        let localUrl = NSURL(fileURLWithPath: NSHomeDirectory())
        let download = self.manager.downloadFileAtURL(url!, toDirectory: localUrl, withName: name, andDelegate: self)
        self.downloads.append(download)

        let insertIndexPath = NSIndexPath(forRow: self.downloads.count - 1, inSection: 0)
        self.downloadsTableView.insertRowsAtIndexPaths([insertIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
}

extension DownloadsViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.downloads.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kDownloadCellidentifier) as! DownloadTableViewCell
        let download: TCBlobDownload = self.downloads[indexPath.row]

        if let fileName = download.fileName {
            cell.labelFileName.text = fileName
        } else {
            cell.labelFileName.text = "..."
        }

        if download.downloadTask.state == NSURLSessionTaskState.Running {
            cell.buttonPause.setTitle("Pause", forState: UIControlState.Normal)
        } else if download.downloadTask.state == NSURLSessionTaskState.Suspended {
            cell.buttonPause.setTitle("Resume", forState: UIControlState.Normal)
        }

        cell.progress = download.progress
        cell.labelDownload.text = download.downloadTask.originalRequest!.URL?.absoluteString
        cell.download = download
        cell.pauseHandler = { (cell) in
            if cell.download!.downloadTask.state == NSURLSessionTaskState.Running {
                cell.download!.suspend()
            } else {
                cell.download!.resume()
            }
            self.downloadsTableView.reloadData()
        }
        
        cell.cancelHandler = { (cell) in
            cell.download!.cancel()
        }

        return cell
    }

}

extension DownloadsViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70.0
    }
}

extension DownloadsViewController: TCBlobDownloadDelegate {
    
    func download(download: TCBlobDownload, didProgress progress: Float, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let downloads: NSArray = self.downloads
        let index = downloads.indexOfObject(download)
        let updateIndexPath = NSIndexPath(forRow: index, inSection: 0)

        let cell = self.downloadsTableView.cellForRowAtIndexPath(updateIndexPath) as! DownloadTableViewCell
        cell.progress = progress
    }

    func download(download: TCBlobDownload, didFinishWithError error: NSError?, atLocation location: NSURL?) {
        let downloads: NSArray = self.downloads
        let index = downloads.indexOfObject(download)
        self.downloads.removeAtIndex(index)
        
        let title = error != nil ? "Downloading Failed" : "Download succeded"
        let message = error != nil ? error!.description : "Located at path " + download.destinationURL.path!
        let controller = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(controller, animated: true, completion: nil)
        
        if nil == error {
            UIPasteboard.generalPasteboard().string = download.destinationURL.URLByDeletingLastPathComponent!.path!
        }

        let deleteIndexPath = NSIndexPath(forRow: index, inSection: 0)
        self.downloadsTableView.deleteRowsAtIndexPaths([deleteIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
}
