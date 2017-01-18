/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Foundation
import UIKit

extension UITextField {

    /**
     Method sets the line height for the label text

     - parameter lineHeight: CGFloat
     */
    func setLineHeight(_ lineHeight: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.0
        paragraphStyle.lineHeightMultiple = lineHeight
        paragraphStyle.alignment = self.textAlignment

        let attrString = NSMutableAttributedString(string: self.text!)
        attrString.addAttribute(NSFontAttributeName, value: self.font, range: NSRange(location: 0, length: attrString.length))
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range: NSRange(location: 0, length: attrString.length))
        self.attributedText = attrString
    }
    
    func isTruncated() -> Bool {
        
        if let string = self.text {
            
            guard let currentFont = self.font else {
                return false
            }
            let size: CGSize = (string as NSString).boundingRect(with:
                CGSize(width: self.frame.size.width, height: CGFloat.greatestFiniteMagnitude),
                options: NSStringDrawingOptions.usesLineFragmentOrigin,
                attributes: [NSFontAttributeName: currentFont],
                context: nil).size
            
            if (size.height > self.bounds.size.height) {
                return true
            }
        }
        
        return false
    }
}
