//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-ios
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
    @IBOutlet private weak var label: UILabel!
    
    var labelText: String? {
        get { return label.text }
        set { label.text = newValue }
    }
}
