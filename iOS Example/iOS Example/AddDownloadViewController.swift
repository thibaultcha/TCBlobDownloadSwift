//
//  AddDownloadViewController.swift
//  iOS Example
//
//  Created by Thibault Charbonnier on 13/01/15.
//  Copyright (c) 2015 Thibault Charbonnier. All rights reserved.
//

import UIKit
import TCBlobDownloadSwift

class AddDownloadViewController: UIViewController {

    weak var delegate: DownloadsViewController?

    @IBOutlet weak var fieldURL: UITextField!

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
        let downloadURL = NSURL(string: self.fieldURL.text)
        self.delegate?.addDownloadWithURL(downloadURL)


        // http://ipv4.download.thinkbroadband.com/100MB.zip
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
