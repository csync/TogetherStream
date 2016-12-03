//
//  SettingsViewController.swift
//  Stormtrooper
//
//  Created by Nathan Hekman on 11/23/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit
import FBSDKLoginKit


class SettingsViewController: UIViewController {
	@IBOutlet weak var facebookLoginButton: FBSDKLoginButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
		facebookLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
		NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "FBSDKAccessTokenDidChangeNotification"), object: nil, queue: nil) { notification in
			print(notification)
		}
		
		
		if let token = FBSDKAccessToken.current() {
			let request = FBSDKGraphRequest.init(graphPath: "me", parameters: nil)
			request?.start() {(request, result, error) in
				print(error.debugDescription)
			}
		}
		
		
		
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }


}
