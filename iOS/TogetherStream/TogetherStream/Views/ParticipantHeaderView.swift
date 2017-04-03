//
//  ParticipantHeaderView.swift
//  TogetherStream
//
//  Created by Daniel Firsht on 3/24/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import UIKit

class ParticipantHeaderView: UIView {
    @IBOutlet weak var numberParticipantsLabel: UILabel!
    
    class func instanceFromNib() -> ParticipantHeaderView {
        return UINib(nibName: "ParticipantHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ParticipantHeaderView
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
