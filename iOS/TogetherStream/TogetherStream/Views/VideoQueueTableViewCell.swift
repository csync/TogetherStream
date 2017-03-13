//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-ios
//

import UIKit

class VideoQueueTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var thumbnailImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var channelLabel: UILabel!
    
    var videoID: String?
    
    private let highlightedBackgroundColor = UIColor(red: 59/255, green: 59/255, blue: 59/255, alpha: 1.0)
    private let unhighlightedBackgroundColor = UIColor(red: 40/255, green: 36/255, blue: 36/255, alpha: 1.0)
    
    private var _isPreviousVideo = false
    private var _isCurrentVideo = false
    
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
    
    /// Is this the video immediately prior to the current video in the queue?
    /// (If so, then its separator will be hidden.)
    var isPreviousVideo: Bool {
        get { return _isPreviousVideo }
        set {
            _isPreviousVideo = newValue
            let visibleSeparator = UIEdgeInsetsMake(0, 15, 0, 0)
            let hiddenSeparator = UIEdgeInsetsMake(0, 0, 0, bounds.size.width)
            separatorInset = _isPreviousVideo ? hiddenSeparator : visibleSeparator
        }
    }
    
    /// Is this the current video in the queue?
    /// (If so, then its design will be updated.)
    var isCurrentVideo: Bool {
        get { return _isCurrentVideo }
        set {
            _isCurrentVideo = newValue
            if _isCurrentVideo {
                // update design for current video
                backgroundColor = highlightedBackgroundColor
                contentView.backgroundColor = highlightedBackgroundColor
                separatorInset = UIEdgeInsetsMake(0, 0, 0, bounds.size.width)
            } else {
                // update design for queued video
                backgroundColor = unhighlightedBackgroundColor
                contentView.backgroundColor = unhighlightedBackgroundColor
                separatorInset = UIEdgeInsetsMake(0, 15, 0, 0)
            }
        }
    }
}
