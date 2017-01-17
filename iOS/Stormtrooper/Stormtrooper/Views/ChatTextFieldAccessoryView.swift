//
//  ChatTextFieldAccessoryView.swift
//  Stormtrooper
//
//  Created by Nathan Hekman on 1/17/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import UIKit

class ChatTextFieldAccessoryView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    class func instanceFromNib() -> ChatTextFieldAccessoryView {
        return UINib(nibName: "ChatTextFieldAccessoryView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ChatTextFieldAccessoryView
    }
    

}
