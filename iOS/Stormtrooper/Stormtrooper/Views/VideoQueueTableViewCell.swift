//
//  VideoQueueTableViewCell.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 1/27/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import UIKit

class VideoQueueTableViewCell: UITableViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var channelTitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
