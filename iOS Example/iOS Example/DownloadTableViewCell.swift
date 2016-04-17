//
//  DownloadTableViewCell.swift
//  iOS Example
//
//  Created by Thibault Charbonnier on 14/01/15.
//  Copyright (c) 2015 Thibault Charbonnier. All rights reserved.
//

import UIKit
import TCBlobDownloadSwift

typealias DownloadTableViewCellHandler = (cell: DownloadTableViewCell) -> Void

class DownloadTableViewCell : UITableViewCell {

    var download: TCBlobDownload?
    
    @IBOutlet weak var labelDownload: UILabel!
    @IBOutlet weak var labelFileName: UILabel!
    @IBOutlet weak var buttonPause: UIButton!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    
    var pauseHandler: DownloadTableViewCellHandler?
    var cancelHandler: DownloadTableViewCellHandler?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.buttonPause.addTarget(self, action: #selector(didPressPauseButton(_:event:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.buttonCancel.addTarget(self, action: #selector(didPressCancelButton(_:event:)), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func didPressCancelButton(sender: UIButton!, event: UIEvent) {
        self.cancelHandler?(cell: self)
    }

    func didPressPauseButton(sender: UIButton!, event: UIEvent) {
        self.pauseHandler?(cell: self)
    }
    
    var progress: Float = 0 {
        didSet {
            progress = min(1, progress)
            progress = max(0, progress)
            self.progressView.progress = progress
        }
    }

}
