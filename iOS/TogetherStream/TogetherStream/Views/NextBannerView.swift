//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-ios
//

import UIKit

class NextBannerView: UIView {

    @IBOutlet weak var nextButton: UIButton!
    class func instanceFromNib() -> NextBannerView {
        return UINib(nibName: "NextBannerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! NextBannerView
    }

}
