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
	let accountDataManager = AccountDataManager.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
		self.setupFacebookLogin()
    }
    
    
    func setupFacebookLogin() {
        accountDataManager.setupLoginButton(facebookLoginButton)
		facebookLoginButton.delegate = self
    }

    @IBAction func skipTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension LoginViewController: FBSDKLoginButtonDelegate {
	func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
		if result.isCancelled {
			// User canceled login
		}
		else if result.declinedPermissions.count == 0 {
			// User accepted all permissions
			if accountDataManager.profile != nil {
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
