//
//  ProfileViewController.swift
//  Stormtrooper
//
//  Created by Nathan Hekman on 11/23/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit
import FBSDKLoginKit


class ProfileViewController: UIViewController {
	@IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
	let facebookDataManager = FacebookDataManager.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
		facebookDataManager.setupLoginButton(facebookLoginButton)
		
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.setAnimationsEnabled(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }


}

extension ProfileViewController: FBSDKLoginButtonDelegate {
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if result.isCancelled {
            // User canceled login
        }
        else if result.declinedPermissions.count == 0 {
            // User accepted all permissions
            if facebookDataManager.profile != nil {
                // done
            }
            else{
                FBSDKProfile.loadCurrentProfile() { profile, error in
                    if let error = error {
                        print(error)
                    }
                    else {
                        // done
                    }
                }
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {}
}
