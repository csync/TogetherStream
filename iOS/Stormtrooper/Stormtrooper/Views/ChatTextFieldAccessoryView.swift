//
//  ChatTextFieldAccessoryView.swift
//  Stormtrooper
//
//  Created by Nathan Hekman on 1/17/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import UIKit

class ChatTextFieldAccessoryView: UIView {

    @IBOutlet weak var cancelButton: UIButton!

    
    class func instanceFromNib() -> ChatTextFieldAccessoryView {
        return UINib(nibName: "ChatTextFieldAccessoryView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ChatTextFieldAccessoryView
    }
    
    
    

}
