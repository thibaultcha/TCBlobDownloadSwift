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

class AddDownloadViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    weak var delegate: DownloadsViewController?

    @IBOutlet weak var fieldURL: UITextField!
    
    @IBOutlet weak var fieldName: UITextField!

    let downloads = [ Download(name: "10MB", url: "http://ipv4.download.thinkbroadband.com/10MB.zip"),
                      Download(name: "50MB", url: "http://ipv4.download.thinkbroadband.com/50MB.zip"),
                      Download(name: "100MB", url: "http://ipv4.download.thinkbroadband.com/100MB.zip"),
                      Download(name: "512MB", url: "http://ipv4.download.thinkbroadband.com/512MB.zip") ]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onCancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onAddDownload(sender: UIBarButtonItem) {
        self.addDownload(fromString: self.fieldURL.text!)
    }

    func addDownload(fromString string: String) {
        let downloadURL = NSURL(string: string)
        self.delegate?.addDownloadWithURL(downloadURL, name: self.fieldName.text)

        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: UITableViewDataSource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.downloads.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("addDownloadCell", forIndexPath: indexPath) 

        cell.textLabel?.text = self.downloads[indexPath.row].name
        
        return cell
    }

    // MARK: UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.fieldURL.text = self.downloads[indexPath.row].url
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }

}
