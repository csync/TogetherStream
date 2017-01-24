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
    @IBOutlet var selectionIndicator: UIImageView!

    let unselectedImageSource = "addFriends.png"
    let selectedImageSource   = "addedContent.png"
    var friendIsSelected = false

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func onTap() {
        friendIsSelected = !friendIsSelected

        if (friendIsSelected) {
            if let image = UIImage(named: selectedImageSource) {
                selectionIndicator.image = image
            }
        } else {
            if let image = UIImage(named: unselectedImageSource) {
                selectionIndicator.image = image
            }
        }

    }
    
}
