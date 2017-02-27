//
//  NextBannerView.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 1/23/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import UIKit

class NextBannerView: UIView {

    @IBOutlet weak var nextButton: UIButton!
    class func instanceFromNib() -> NextBannerView {
        return UINib(nibName: "NextBannerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! NextBannerView
    }

}
