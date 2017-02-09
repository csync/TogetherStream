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
        setupBackButton()
    }
    
    private func setupBackButton() {
        let backButton = UIButton(type: .custom)
        backButton.setImage(#imageLiteral(resourceName: "back_stream"), for: .normal)
        backButton.frame = CGRect(x: 0, y: 0, width: 17, height: 17)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        let backButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.setLeftBarButtonItems([backButtonItem], animated: false)
    }
    
    private func open(url: String) {
        guard let url = URL(string: url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @objc private func backTapped() {
        let _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tappedCSync() {
        open(url: "https://ibm.biz/together-stream-csync-logo")
    }
    
    @IBAction func tappedBluemix() {
        open(url: "https://ibm.biz/together-stream-bluemix-logo")
    }
    
    @IBAction func tappedMIL() {
        open(url: "https://ibm.biz/together-stream-mil-logo")
    }
    
    @IBAction func tappedYoutube() {
        open(url: "https://ibm.biz/together-stream-youtube-logo")
    }
    
    
}
