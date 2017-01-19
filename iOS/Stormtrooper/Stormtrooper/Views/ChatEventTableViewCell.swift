//
//  ChatEventTableViewCell.swift
//  Stormtrooper
//
//  Created by Nathan Hekman on 1/17/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import UIKit

class ChatEventTableViewCell: UITableViewCell {
	@IBOutlet weak var profileImageView: UIImageView!
	@IBOutlet weak var messageLabel: UILabel!
	@IBOutlet weak var nameLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
