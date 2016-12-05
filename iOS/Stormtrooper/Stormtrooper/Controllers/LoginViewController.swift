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
    }
    
    
	@IBAction func pressedMe(_ sender: Any) {
		accountDataManager.fetchUserInfo {
			print("done")
		}
	}

    @IBAction func skipTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



}
