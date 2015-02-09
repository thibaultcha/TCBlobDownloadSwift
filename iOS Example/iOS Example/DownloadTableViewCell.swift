//
//  DownloadTableViewCell.swift
//  iOS Example
//
//  Created by Thibault Charbonnier on 14/01/15.
//  Copyright (c) 2015 Thibault Charbonnier. All rights reserved.
//

import UIKit

class DownloadTableViewCell : UITableViewCell {

    @IBOutlet weak var labelDownload: UILabel!

    @IBOutlet weak var labelFileName: UILabel!
    
    @IBOutlet weak var buttonPause: UIButton!

    @IBOutlet weak var buttonCancel: UIButton!

    @IBOutlet weak var progressView: UIProgressView!

    var progress: Float = 0 {
        didSet {
            progress = min(1, progress)
            progress = max(0, progress)
            self.progressView.progress = progress
        }
    }

}
