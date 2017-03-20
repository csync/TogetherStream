//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-ios
//

import CoreFoundation
import Foundation
import UIKit

extension UITableView {
    
    /// Scrolls the table view to the bottom row.
    ///
    /// - Parameter animated: Whether the scroll is animated or not.
    func scrollTableViewToBottom(animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            let numberOfSections = self.numberOfSections
            let numberOfRows = self.numberOfRows(inSection: numberOfSections-1)
            if numberOfRows > 0 {
                let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                self.scrollToRow(at: indexPath, at: .bottom, animated: animated)
            }
        }
    }
}
