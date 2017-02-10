//
//  AboutViewController.swift
//  Stormtrooper
//
//  Created by Glenn R. Fisher on 2/2/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    @IBAction func tappedCSync()   { open(url: "https://ibm.biz/together-stream-csync-logo")   }
    @IBAction func tappedBluemix() { open(url: "https://ibm.biz/together-stream-bluemix-logo") }
    @IBAction func tappedMIL()     { open(url: "https://ibm.biz/together-stream-mil-logo")     }
    @IBAction func tappedYoutube() { open(url: "https://ibm.biz/together-stream-youtube-logo") }
    
    private func open(url: String) {
        guard let url = URL(string: url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
