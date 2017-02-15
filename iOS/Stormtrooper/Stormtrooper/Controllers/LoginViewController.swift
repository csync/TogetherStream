//
//  LoginViewController.swift
//  Stormtrooper
//
//  Created by Nathan Hekman on 11/23/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit
import FBSDKLoginKit


/// View controller for "Login" screen
class LoginViewController: UIViewController {
	@IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
	/// Shorthand for shared FacebookDataManager
	let facebookDataManager = FacebookDataManager.sharedInstance
    /// Shorthand for shared AccountDataManager
    let accountDataManager = AccountDataManager.sharedInstance
    /// Shorthand for shared CSyncDataManager
    let csyncDataManager = CSyncDataManager.sharedInstance
    /// Loading indicator used after logging in.
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    override func viewDidLoad() {
        super.viewDidLoad()
        trackScreenView()
		setupFacebookLoginButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.setAnimationsEnabled(true)
    }
    
    /// Configures the Facebook login button.
    func setupFacebookLoginButton() {
        facebookDataManager.setupLoginButton(facebookLoginButton)
		facebookLoginButton.delegate = self
    }
    
    /// When CSync logo is tapped, show the CSync homepage.
    ///
    /// - Parameter sender: the button tapped.
    @IBAction func csyncTapped(_ sender: Any) {
        open(url: "https://ibm.biz/together-stream-csync-logo")
    }
    
    /// Open the given URL.
    ///
    /// - Parameter url: the URL to open.
    private func open(url: String) {
        guard let url = URL(string: url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

extension LoginViewController: FBSDKLoginButtonDelegate {
	/// Checks the status of Facebook login. If successful, authenticate with the server
    /// and CSync.
	///
	/// - Parameters:
	///   - loginButton: The button pressed.
	///   - result: The result of the login attempt.
	///   - error: The error of the login attempt.
	func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        // Check if login was successful
        guard !result.isCancelled, result.declinedPermissions.count == 0 else { return }
        // Disable additional login attempts while configuring.
        loginButton.isEnabled = false
        activityIndicator.startAnimating()
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
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
                // Authenticate with CSync
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
                        // Successfully logged in
                        self.activityIndicator.stopAnimating()
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
		}
	}
	
	func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {}
}
