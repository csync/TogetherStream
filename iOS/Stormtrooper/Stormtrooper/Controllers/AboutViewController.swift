//
//  AboutViewController.swift
//  Stormtrooper
//
//  Created by Glenn R. Fisher on 2/2/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    @IBAction func tappedCSync() {
        let url = URL(string: "https://www.google.com")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func tappedBluemix() {
        let url = URL(string: "https://www.google.com")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func tappedMIL() {
        let url = URL(string: "https://www.google.com")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func tappedYoutube() {
        let url = URL(string: "https://www.google.com")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
