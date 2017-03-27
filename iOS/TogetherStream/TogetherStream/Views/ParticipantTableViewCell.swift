//
//  ParticipantTableViewCell.swift
//  TogetherStream
//
//  Created by Daniel Firsht on 3/27/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import UIKit

class ParticipantTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabelView: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
