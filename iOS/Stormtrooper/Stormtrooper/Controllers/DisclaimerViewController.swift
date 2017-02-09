//
//  DisclaimerViewController.swift
//  Stormtrooper
//
//  Created by Glenn R. Fisher on 2/9/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import UIKit

class DisclaimerViewController: UIViewController {
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
    
    @objc private func backTapped() {
        let _ = navigationController?.popViewController(animated: true)
    }
}
