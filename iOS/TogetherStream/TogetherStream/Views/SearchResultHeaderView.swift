//
//  SearchResultHeaderView.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 1/21/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import UIKit

class SearchResultHeaderView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    
    class func instanceFromNib() -> SearchResultHeaderView {
        return UINib(nibName: "SearchResultHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SearchResultHeaderView
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
