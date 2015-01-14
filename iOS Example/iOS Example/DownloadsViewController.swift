//
//  DownloadsViewController.swift
//  iOS Example
//
//  Created by Thibault Charbonnier on 12/01/15.
//  Copyright (c) 2015 Thibault Charbonnier. All rights reserved.
//

import UIKit
import TCBlobDownloadSwift

private let kDownloadCellidentifier = "downloadCellIdentifier"

class DownloadsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let manager = TCBlobDownloadManager.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
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
        println("Adding download \(url)")
        self.manager.downloadFileAtURL(url!, toDirectory: nil, withName: nil, andDelegate: nil)
    }

    // MARK: UITableViewDataSource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.manager.currentDownloadsFilteredByState(nil).count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kDownloadCellidentifier) as UITableViewCell

        return cell
    }
}
