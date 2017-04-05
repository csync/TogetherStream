//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-ios
//

import CoreFoundation
import Foundation
import UIKit

/**

 MARK: IBInspectable

 */
extension UIView {
    
    /// Allows you to modify the corner radius of a view in storyboard
    @IBInspectable var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}

@IBDesignable class GradientView: UIView {
    @IBInspectable var topColor: UIColor = UIColor.white
    @IBInspectable var bottomColor: UIColor = UIColor.black
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        guard let thisLayer = layer as? CAGradientLayer else {
            return
        }
        thisLayer.colors = [topColor.cgColor, bottomColor.cgColor]
    }
}
