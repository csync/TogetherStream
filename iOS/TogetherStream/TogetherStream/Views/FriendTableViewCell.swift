//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-ios
//

import UIKit

class FriendTableViewCell: UITableViewCell {
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var selectionIndicator: UIImageView!

    let unselectedImageSource = "addFriends.png"
    let selectedImageSource   = "addedContent.png"
    var friendIsSelected = false {
        didSet {
            if friendIsSelected {
                if let image = UIImage(named: selectedImageSource) {
                    DispatchQueue.main.async {
                        self.selectionIndicator.image = image
                    }
                }
            } else {
                if let image = UIImage(named: unselectedImageSource) {
                    DispatchQueue.main.async {
                        self.selectionIndicator.image = image
                    }

                }
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
