//
//  AboutViewController.swift
//  Stormtrooper
//
//  Created by Glenn R. Fisher on 2/2/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trackScreenView()
    }
    
    private func open(url: String) {
        guard let url = URL(string: url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @objc private func backTapped() {
        Utils.sendGoogleAnalyticsEvent(withCategory: "About", action: "SelectedBackButton")
        let _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tappedCSync() {
        Utils.sendGoogleAnalyticsEvent(withCategory: "About", action: "SelectedCSync")
        open(url: "https://ibm.biz/together-stream-csync-logo")
    }
    
    @IBAction func tappedBluemix() {
        Utils.sendGoogleAnalyticsEvent(withCategory: "About", action: "SelectedBluemix")
        open(url: "https://ibm.biz/together-stream-bluemix-logo")
    }
    
    @IBAction func tappedMIL() {
        Utils.sendGoogleAnalyticsEvent(withCategory: "About", action: "SelectedMIL")
        open(url: "https://ibm.biz/together-stream-mil-logo")
    }
    
    @IBAction func tappedYoutube() {
        Utils.sendGoogleAnalyticsEvent(withCategory: "About", action: "SelectedYoutube")
        open(url: "https://ibm.biz/together-stream-youtube-logo")
    }
}
