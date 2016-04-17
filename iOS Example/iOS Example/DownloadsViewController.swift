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
            let destinationNC = segue.destinationViewController as! UINavigationController
            let destinationVC = destinationNC.topViewController as! AddDownloadViewController
            destinationVC.delegate = self
        }
    }

    private func getDownloadFromButtonPress(sender: UIButton, event: UIEvent) -> (download: TCBlobDownload, indexPath: NSIndexPath) {
        let touch = (event.touchesForView(sender)?.first)! as UITouch
        let location = touch.locationInView(self.downloadsTableView)
        let indexPath = self.downloadsTableView.indexPathForRowAtPoint(location)

        return (self.downloads[indexPath!.row], indexPath!)
    }

    // MARK: Downloads management

    func addDownloadWithURL(url: NSURL?, name: String?) {
        let download = self.manager.downloadFileAtURL(url!, toDirectory: nil, withName: name, andDelegate: self)
        self.downloads.append(download)

        let insertIndexPath = NSIndexPath(forRow: self.downloads.count - 1, inSection: 0)
        self.downloadsTableView.insertRowsAtIndexPaths([insertIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }

    func didPressPauseButton(sender: UIButton!, event: UIEvent) {
        let e = self.getDownloadFromButtonPress(sender, event: event)

        if e.download.downloadTask.state == NSURLSessionTaskState.Running {
           e.download.suspend()
        } else {
            e.download.resume()
        }

        self.downloadsTableView.reloadRowsAtIndexPaths([e.indexPath], withRowAnimation: UITableViewRowAnimation.None)
    }

    func didPressCancelButton(sender: UIButton!, event: UIEvent) {
        let e = self.getDownloadFromButtonPress(sender, event: event)

        e.download.cancel()
    }

    // MARK: UITableViewDataSource

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
        cell.buttonPause.addTarget(self, action: #selector(DownloadsViewController.didPressPauseButton(_:event:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.buttonCancel.addTarget(self, action: #selector(DownloadsViewController.didPressCancelButton(_:event:)), forControlEvents: UIControlEvents.TouchUpInside)

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

        let cell = self.downloadsTableView.cellForRowAtIndexPath(updateIndexPath) as! DownloadTableViewCell
        cell.progress = progress
    }

    func download(download: TCBlobDownload, didFinishWithError: NSError?, atLocation location: NSURL?) {
        let downloads: NSArray = self.downloads
        let index = downloads.indexOfObject(download)
        self.downloads.removeAtIndex(index)

        let deleteIndexPath = NSIndexPath(forRow: index, inSection: 0)
        self.downloadsTableView.deleteRowsAtIndexPaths([deleteIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }

}
