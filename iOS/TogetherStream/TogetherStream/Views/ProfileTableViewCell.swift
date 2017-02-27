//
//  ProfileTableViewCell.swift
//  Stormtrooper
//
//  Created by Glenn R. Fisher on 1/31/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
    @IBOutlet private weak var label: UILabel!
    
    var labelText: String? {
        get { return label.text }
        set { label.text = newValue }
    }
}
