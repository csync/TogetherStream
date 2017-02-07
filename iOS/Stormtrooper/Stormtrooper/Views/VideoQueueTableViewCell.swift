//
//  VideoQueueTableViewCell.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 1/27/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import UIKit

class VideoQueueTableViewCell: UITableViewCell {
    @IBOutlet private weak var playImageView: UIImageView!
    @IBOutlet private weak var numberLabel: UILabel!
    @IBOutlet private weak var thumbnailImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var channelLabel: UILabel!
    
    private let highlightedBackgroundColor = UIColor(red: 251/255, green: 252/255, blue: 252/255, alpha: 0.10)
    private let unhighlightedBackgroundColor = UIColor(red: 40/255, green: 36/255, blue: 36/255, alpha: 1.0)
    
    var number: Int? {
        get { return Int(numberLabel.text ?? "") }
        set { numberLabel.text = "\(newValue)" }
    }
    
    var thumbnail: UIImage? {
        get { return thumbnailImageView.image }
        set { thumbnailImageView.image = newValue }
    }
    
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var channel: String? {
        get { return channelLabel.text }
        set { channelLabel.text = newValue }
    }
    
    private var _isCurrentVideo = false
    var isCurrentVideo: Bool {
        get { return _isCurrentVideo }
        set {
            _isCurrentVideo = newValue
            if _isCurrentVideo {
                // update design for current video
                playImageView.isHidden = false
                numberLabel.isHidden = true
                contentView.backgroundColor = highlightedBackgroundColor
                separatorInset = UIEdgeInsetsMake(0, 0, 0, bounds.size.width)
            } else {
                // update design for queued video
                playImageView.isHidden = true
                numberLabel.isHidden = false
                contentView.backgroundColor = unhighlightedBackgroundColor
            }
        }
    }
}
