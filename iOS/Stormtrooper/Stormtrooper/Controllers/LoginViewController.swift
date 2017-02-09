//
//  LoginViewController.swift
//  Stormtrooper
//
//  Created by Nathan Hekman on 11/23/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit
import FBSDKLoginKit


class LoginViewController: UIViewController {
	@IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
	let facebookDataManager = FacebookDataManager.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
		self.setupFacebookLogin()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.setAnimationsEnabled(true)
    }
    
    func setupFacebookLogin() {
        facebookDataManager.setupLoginButton(facebookLoginButton)
		facebookLoginButton.delegate = self
    }
    
    @IBAction func csyncTapped(_ sender: Any) {
        open(url: "https://ibm.biz/together-stream-csync-logo")
    }
    
    private func open(url: String) {
        guard let url = URL(string: url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

extension LoginViewController: FBSDKLoginButtonDelegate {
	func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
		if result.isCancelled {
			// User canceled login
		}
		else if result.declinedPermissions.count == 0 {
			// User accepted all permissions
			if facebookDataManager.profile != nil {
				DispatchQueue.main.async {
					self.dismiss(animated: true, completion: nil)
				}
			}
			else{
				FBSDKProfile.loadCurrentProfile() { profile, error in
					if let error = error {
						print(error)
					}
					else {
						DispatchQueue.main.async {
							self.dismiss(animated: true, completion: nil)
						}
					}
				}
			}
		}
	}
	
	func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {}
}
