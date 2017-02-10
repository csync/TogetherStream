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
    let accountDataManager = AccountDataManager.sharedInstance
    let csyncDataManager = CSyncDataManager.sharedInstance
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    override func viewDidLoad() {
        super.viewDidLoad()
        trackScreenView()
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
        guard !result.isCancelled, result.declinedPermissions.count == 0 else { return }
        loginButton.isEnabled = false
        activityIndicator.startAnimating()
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        // User accepted all permissions
        FBSDKProfile.loadCurrentProfile() { profile, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error Loading Profile", message: error!.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                    self.activityIndicator.stopAnimating()
                    loginButton.isEnabled = true
                }
                return
            }
            // Loading a profile insures that the access token is available so error is not expected
            guard let accessToken = self.facebookDataManager.accessToken else { return }
            // Sign user up with server
            self.accountDataManager.signup(withFacebookAccessToken: accessToken) { error in
                guard error == nil else {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error Creating Account", message: error!.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                        self.activityIndicator.stopAnimating()
                        loginButton.isEnabled = true
                    }
                    return
                }
                self.csyncDataManager.authenticate(withFBAccessToken: accessToken) {authData, error in
                    guard error == nil else {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Error Setting up Account", message: error!.localizedDescription, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alert, animated: true)
                            self.activityIndicator.stopAnimating()
                            loginButton.isEnabled = true
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
		}
	}
	
	func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {}
}
