//
//  StreamTableViewCell.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 1/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import UIKit

class StreamTableViewCell: UITableViewCell {
	@IBOutlet weak var profileImageView: UIImageView!
	@IBOutlet weak var streamNameLabel: UILabel!
	@IBOutlet weak var hostNameLabel: UILabel!
	@IBOutlet weak var currentVideoThumbnailImageView: UIImageView!
	@IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak var cardView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cardView.layer.shadowColor = UIColor.stormtrooperShadow.cgColor
        cardView.layer.shadowRadius = 4
        cardView.layer.shadowOpacity = 0.5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
