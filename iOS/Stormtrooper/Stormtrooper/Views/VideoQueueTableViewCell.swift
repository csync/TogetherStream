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
    
    private let highlightedBackgroundColor = UIColor(red: 59/255, green: 59/255, blue: 59/255, alpha: 1.0)
    private let unhighlightedBackgroundColor = UIColor(red: 40/255, green: 36/255, blue: 36/255, alpha: 1.0)
    
    private var _isCurrentVideo = false
    
    /// The video's position in the playlist.
    var number: String? {
        get { return numberLabel.text }
        set { numberLabel.text = newValue }
    }
    
    /// The video's thumbnail.
    var thumbnail: UIImage? {
        get { return thumbnailImageView.image }
        set { thumbnailImageView.image = newValue }
    }
    
    /// The video's title.
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    /// The video's channel.
    var channel: String? {
        get { return channelLabel.text }
        set { channelLabel.text = newValue }
    }
    
    private var _isCurrentVideo = false
    /// Is this the current video in the queue?
    /// (If so, then its design will be updated.)
    var isCurrentVideo: Bool {
        get { return _isCurrentVideo }
        set {
            _isCurrentVideo = newValue
            if _isCurrentVideo {
                // update design for current video
                playImageView.isHidden = false
                numberLabel.isHidden = true
                backgroundColor = highlightedBackgroundColor
                contentView.backgroundColor = highlightedBackgroundColor
                separatorInset = UIEdgeInsetsMake(0, 0, 0, bounds.size.width)
            } else {
                // update design for queued video
                playImageView.isHidden = true
                numberLabel.isHidden = false
                backgroundColor = unhighlightedBackgroundColor
                contentView.backgroundColor = unhighlightedBackgroundColor
                separatorInset = UIEdgeInsetsMake(0, 15, 0, 0)
            }
        }
    }
}
