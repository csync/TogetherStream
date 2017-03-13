//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-ios
//

import Foundation
import UIKit
import Google

extension UIViewController {
    
    /// The view controller that the user is most likely interacting with.
    var mostActiveViewController: UIViewController {
        if let presentedViewController = self.presentedViewController {
            // recurse using the presented view controller
            return presentedViewController.mostActiveViewController
        }
        
        if let viewController = self as? UISplitViewController {
            if let primary = viewController.viewControllers.first {
                // recurse using the primary view controller
                return primary.mostActiveViewController
            }
            return viewController
        }
        
        if let viewController = self as? UINavigationController {
            if let top = viewController.viewControllers.last {
                // recuse using the top view controller
                return top.mostActiveViewController
            }
            return viewController
        }
        
        if let viewController = self as? UITabBarController {
            if let selected = viewController.selectedViewController {
                // recurse using the selected view controller
                return selected.mostActiveViewController
            }
            return viewController
        }
        
        return self
    }
    
    /// Sends a screen view track of the current the view controller.
    func trackScreenView() {
        // Only send during production
        #if !DEBUG
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: String(describing: type(of: self)))
        let view = GAIDictionaryBuilder.createScreenView().build() as NSDictionary as? [AnyHashable: Any]
        tracker?.send(view)
        #endif
    }
}
