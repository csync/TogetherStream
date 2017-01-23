//
//  UIViewControllerExtension.swift
//  BluePic
//
//  Created by Alex Buck on 6/8/16.
//  Copyright © 2016 MIL. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {


    /**
     Method returns whether the view controller is visible or not

     - parameter viewController: UIViewController

     - returns: Bool
     */
    func isVisible() -> Bool {

        if let navigationController = self.navigationController, let visibleViewController = navigationController.visibleViewController {
            if self == visibleViewController {
                return true
            } else {
                return false
            }
        } else {
            return false
        }

    }
    
    /**
     Find the view controller that the user is most likely interacting with.
 
     - parameter from: The view controller from which to begin the search.
     - returns: The view controller that the user is most likely interacting with.
     */
    static func findBestViewController(from viewController: UIViewController) -> UIViewController {
        if let presentedViewController = viewController.presentedViewController {
            // recurse using the presented view controller
            return findBestViewController(from: presentedViewController)
        }
        
        if let viewController = viewController as? UISplitViewController {
            if let primary = viewController.viewControllers.first {
                // recurse using the primary view controller
                return findBestViewController(from: primary)
            }
            return viewController
        }
        
        if let viewController = viewController as? UINavigationController {
            if let top = viewController.viewControllers.last {
                // recuse using the top view controller
                return findBestViewController(from: top)
            }
            return viewController
        }
        
        if let viewController = viewController as? UITabBarController {
            if let selected = viewController.selectedViewController {
                // recurse using the selected view controller
                return findBestViewController(from: selected)
            }
            return viewController
        }
        
        return viewController
    }
}
