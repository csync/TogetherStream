//
//  UIColor.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 1/18/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    /// The orangle color used throughout the app.
    @nonobjc class var togetherStreamOrange: UIColor {
        return UIColor(colorLiteralRed: 216.0 / 255, green: 65.0 / 255, blue: 6.0 / 255, alpha: 1)
    }
    
    /// The color of the dropshadow of the cards.
    @nonobjc class var togetherStreamShadow: UIColor {
        return UIColor(colorLiteralRed: 206.0 / 255, green: 206.0 / 255, blue: 206.0 / 255, alpha: 1)
    }
    
    /// The color of the row seperators.
    @nonobjc class var togetherStreamSeperatorGray: UIColor {
        return UIColor(colorLiteralRed: 89.0 / 255, green: 88.0 / 255, blue: 89.0 / 255, alpha: 1)
    }
    
    /// The color of the placeholder text.
    @nonobjc class var togetherStreamPlaceholderGray: UIColor {
        return UIColor(colorLiteralRed: 148.0 / 255, green: 147.0 / 255, blue: 148.0 / 255, alpha: 1)
    }
    
    /// The color of the text used throughout the app.
    @nonobjc class var togetherStreamTextBlack: UIColor {
        return UIColor(colorLiteralRed: 74.0 / 255, green: 74.0 / 255, blue: 74.0 / 255, alpha: 1)
    }
}
