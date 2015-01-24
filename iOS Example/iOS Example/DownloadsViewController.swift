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

class DownloadsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TCBlobDownloadDelegate {

    let manager = TCBlobDownloadManager.sharedInstance

    // Keep track of the current (and probably past soon) downloads
    // This is the tableview's data source
    var downloads = [TCBlobDownload]()

    @IBOutlet weak var downloadsTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "DownloadTableViewCell", bundle: nil)
        self.downloadsTableView.registerNib(nib, forCellReuseIdentifier: kDownloadCellidentifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toAddDownload" {
            let destinationNC = segue.destinationViewController as UINavigationController
            let destinationVC = destinationNC.topViewController as AddDownloadViewController
            destinationVC.delegate = self
        }
    }

    func addDownloadWithURL(url: NSURL?) {
        let download = self.manager.downloadFileAtURL(url!, toDirectory: nil, withName: nil, andDelegate: self)
        self.downloads.append(download)

        let insertIndexPath = NSIndexPath(forRow: self.downloads.count - 1, inSection: 0)
        self.downloadsTableView.insertRowsAtIndexPaths([insertIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }

    // MARK: UITableViewDataSource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.downloads.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kDownloadCellidentifier) as DownloadTableViewCell
        var download: TCBlobDownload = self.downloads[indexPath.row]

        if let fileName = download.fileName {
            cell.labelFileName.text = fileName
        } else {
            cell.labelFileName.text = ""
        }

        if download.downloadTask.state == NSURLSessionTaskState.Running {
            cell.buttonPause.titleLabel?.text = "Pause"
        } else if download.downloadTask.state == NSURLSessionTaskState.Suspended {
            cell.buttonPause.titleLabel?.text = "Resume"
        }

        cell.progress = download.progress

        cell.labelDownload.text = download.downloadTask.originalRequest.URL.absoluteString

        return cell
    }

    // MARK: UITableViewDelegate

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }

    // MARK: TCBlobDownloadDelegate

    func download(download: TCBlobDownload, didProgress progress: Float, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let downloads: NSArray = self.downloads
        let index = downloads.indexOfObject(download)

        let updateIndexPath = NSIndexPath(forRow: index, inSection: 0)
        self.downloadsTableView.reloadRowsAtIndexPaths([updateIndexPath], withRowAnimation: UITableViewRowAnimation.None)
    }

    func download(download: TCBlobDownload, didFinishWithError: NSError?, atLocation location: NSURL?) {
        let downloads: NSArray = self.downloads
        let index = downloads.indexOfObject(download)
        self.downloads.removeAtIndex(index)

        let deleteIndexPath = NSIndexPath(forRow: index, inSection: 0)
        self.downloadsTableView.deleteRowsAtIndexPaths([deleteIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }

}
