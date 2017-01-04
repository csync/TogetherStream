//
//  ChatTableViewCell.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 1/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
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
