//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-ios
//

import UIKit

class ChatTextFieldAccessoryView: UIView {


    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!

    
    class func instanceFromNib() -> ChatTextFieldAccessoryView {
        return UINib(nibName: "ChatTextFieldAccessoryView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ChatTextFieldAccessoryView
    }
    
    
    override func awakeFromNib() {
        
    }
    
    
    

}
