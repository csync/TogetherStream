//
//  FriendTableViewCell.swift
//  Stormtrooper
//
//  Created by Jaime Guajardo on 1/16/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell {
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var friendSelected: UILabel!

    var friendIsSelected = false

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if (selected) {
            friendIsSelected = !friendIsSelected

            if (friendIsSelected) {
                friendSelected.text = "✓"
            } else {
                friendSelected.text = "+"
            }
        }

    }
    
}
