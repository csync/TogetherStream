//
//  AboutViewController.swift
//  Stormtrooper
//
//  Created by Glenn R. Fisher on 2/2/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    @IBOutlet weak var ourSiteTextView: UITextView!
    
    let linkedString = "visit our site."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trackScreenView()
        setupOurSiteLabel()
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        if parent == nil {
            Utils.sendGoogleAnalyticsEvent(withCategory: "About", action: "SelectedBackButton")
        }
    }
    
    private func setupOurSiteLabel() {
        // Add hyperlink to our site
        guard let attributedString = ourSiteTextView.attributedText?.mutableCopy() as? NSMutableAttributedString else {return}
        let linkRange = attributedString.mutableString.range(of: linkedString)
        guard linkRange.location != NSNotFound else {
            return
        }
        attributedString.addAttribute(NSLinkAttributeName, value: "http://ibm.biz/together-stream", range: linkRange)
        let linkAttributes = [
            NSForegroundColorAttributeName: UIColor.stormtrooperTextBlack,
            NSUnderlineColorAttributeName: UIColor.stormtrooperTextBlack,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue] as [String : Any]
        ourSiteTextView.linkTextAttributes = linkAttributes
        ourSiteTextView.attributedText = attributedString
    }
    
    private func open(url: String) {
        guard let url = URL(string: url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
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

extension AboutViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
}
