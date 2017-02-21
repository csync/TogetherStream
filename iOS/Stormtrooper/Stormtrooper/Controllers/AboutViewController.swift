//
//  AboutViewController.swift
//  Stormtrooper
//
//  Created by Glenn R. Fisher on 2/2/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import UIKit

/// View controller for the "About" screen.
class AboutViewController: UIViewController {
    
    @IBOutlet weak var ourSiteTextView: UITextView!
    
    /// The string to add a hyperlink to.
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
    
    /// Sets up the label about visiting our site.
    private func setupOurSiteLabel() {
        // Add hyperlink to our site on the proper part of the label.
        guard let attributedString = ourSiteTextView.attributedText?.mutableCopy() as? NSMutableAttributedString else {return}
        let linkRange = attributedString.mutableString.range(of: linkedString)
        guard linkRange.location != NSNotFound else {
            return
        }
        attributedString.addAttribute(NSLinkAttributeName, value: "http://ibm.biz/together-stream", range: linkRange)
        // Format the linked text
        let linkAttributes = [
            NSForegroundColorAttributeName: UIColor.stormtrooperTextBlack,
            NSUnderlineColorAttributeName: UIColor.stormtrooperTextBlack,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue] as [String : Any]
        ourSiteTextView.linkTextAttributes = linkAttributes
        
        ourSiteTextView.attributedText = attributedString
    }
    
    /// Open the given URL in a Safari view controller.
    ///
    /// - Parameter url: The URL string to open.
    private func open(url: String) {
        guard let url = URL(string: url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    /// Open the CSync website.
    @IBAction func tappedCSync() {
        Utils.sendGoogleAnalyticsEvent(withCategory: "About", action: "SelectedCSync")
        open(url: "https://ibm.biz/together-stream-csync-logo")
    }
    
    /// Open the Bluemix website.
    @IBAction func tappedBluemix() {
        Utils.sendGoogleAnalyticsEvent(withCategory: "About", action: "SelectedBluemix")
        open(url: "https://ibm.biz/together-stream-bluemix-logo")
    }
    
    /// Open the MIL website,
    @IBAction func tappedMIL() {
        Utils.sendGoogleAnalyticsEvent(withCategory: "About", action: "SelectedMIL")
        open(url: "https://ibm.biz/together-stream-mil-logo")
    }
    
    /// Open the YouTube website.
    @IBAction func tappedYoutube() {
        Utils.sendGoogleAnalyticsEvent(withCategory: "About", action: "SelectedYoutube")
        open(url: "https://ibm.biz/together-stream-youtube-logo")
    }
}

extension AboutViewController: UITextViewDelegate {
    /// Enable interacting with the URL in the text view.
    ///
    /// - Parameters:
    ///   - textView: The text view to interact with.
    ///   - URL: The URL to interact with.
    ///   - characterRange: The range the URL is located in.
    ///   - interaction: The type of interaction.
    /// - Returns: Whether the interaction should occur.
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
}
