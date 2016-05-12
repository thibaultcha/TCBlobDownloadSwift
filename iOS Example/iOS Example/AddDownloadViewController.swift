//
//  AddDownloadViewController.swift
//  iOS Example
//
//  Created by Thibault Charbonnier on 13/01/15.
//  Copyright (c) 2015 Thibault Charbonnier. All rights reserved.
//

import UIKit
import TCBlobDownloadSwift

struct Download {
    var name: String
    var url: String
}

class AddDownloadViewController: UIViewController {

    weak var delegate: DownloadsViewController?
    @IBOutlet weak var fieldURL: UITextField!
    @IBOutlet weak var fieldName: UITextField!

    let downloads = [
        Download(name: "7 MB", url: "https://downloadarchive.documentfoundation.org/libreoffice/old/5.1.2.2/mac/x86_64/LibreOffice_5.1.2.2_MacOS_x86-64_langpack_tr.dmg"),
        Download(name: "20 MB", url: "https://download.gimp.org/mirror/pub/gimp/v2.9/gimp-2.9.2.tar.bz2"),
        Download(name: "200 MB", url: "https://downloadarchive.documentfoundation.org/libreoffice/old/5.1.2.2/mac/x86_64/LibreOffice_5.1.2.2_MacOS_x86-64.dmg"),
    ]

    @IBAction func onCancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onAddDownload(sender: UIBarButtonItem) {
        self.addDownload(fromString: self.fieldURL!.text!)
    }

    func addDownload(fromString string: String) {
        let downloadURL = NSURL(string: string)
        self.delegate?.addDownloadWithURL(downloadURL, name: self.fieldName.text)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension AddDownloadViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.downloads.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("addDownloadCell", forIndexPath: indexPath)
        cell.textLabel?.text = self.downloads[indexPath.row].name
        return cell
    }
}

extension AddDownloadViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.fieldURL.text = self.downloads[indexPath.row].url
        self.fieldName.text = self.downloads[indexPath.row].name
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
}
