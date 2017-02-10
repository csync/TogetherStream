//
//  UIViewControllerExtension.swift
//  BluePic
//
//  Created by Alex Buck on 6/8/16.
//  Copyright © 2016 MIL. All rights reserved.
//

import Foundation
import UIKit
import Google

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
    
    func trackScreenView() {
        #if !DEBUG
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: String(describing: self))
        let view = GAIDictionaryBuilder.createScreenView().build() as NSDictionary as? [AnyHashable: Any]
        tracker?.send(view)
        #endif
    }
}
