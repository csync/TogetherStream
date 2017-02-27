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

import UIKit
import Google

class Utils: NSObject {
    
    static let inviteMessage = "Download Together Stream for iOS - A collaborative and synchronized streaming experience.\nhttp://ibm.biz/together-stream-invite-friends"

    /**
     Method gets a key from a plist, both specified in parameters

     - parameter plist: String
     - parameter key:   String

     - returns: String
     */
    class func getStringValueWithKeyFromPlist(_ plist: String, key: String) -> String? {
        if let path: String = Bundle.main.path(forResource: plist, ofType: "plist"),
            let keyList = NSDictionary(contentsOfFile: path),
            let key = keyList.object(forKey: key) as? String {
            return key
        }
        return nil
    }

    /**
    Method returns an instance of the storyboard defined by the storyboardName String parameter

    - parameter storyboardName: UString

    - returns: UIStoryboard
    */
    class func storyboardBoardWithName(_ storyboardName: String) -> UIStoryboard {
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        return storyboard
    }

    /**
    Method returns an instance of the view controller defined by the vcName paramter from the storyboard defined by the storyboardName parameter

    - parameter identifier:     String
    - parameter storyboardName: String

    - returns: UIViewController?
    */
    class func instantiateViewController(withIdentifier identifier: String, fromStoryboardNamed storyboardName: String) -> UIViewController? {
        let storyboard = storyboardBoardWithName(storyboardName)
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }

    /// Creates and sends a Google Analytics event with the given parameters.
    ///
    /// - Parameters:
    ///   - category: The event category.
    ///   - action: The event action.
    ///   - label: The event label.
    ///   - value: The event value.
    class func sendGoogleAnalyticsEvent(withCategory category: String, action: String? = nil, label: String? = nil, value: NSNumber? = nil) {
        #if !DEBUG
        guard
            let event = GAIDictionaryBuilder.createEvent(
                withCategory: category,
                action: action,
                label: label,
                value: value)
                .build() as NSDictionary as? [AnyHashable: Any] else { return}
        GAI.sharedInstance().defaultTracker.send(event)
        #endif
    }
}
