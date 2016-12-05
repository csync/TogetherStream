//
//  AccountDataManager.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 12/5/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation
import FBSDKLoginKit

class AccountDataManager {
	static let sharedInstance = AccountDataManager()
	
	func fetchUserInfo(callback: @escaping () -> ()) {
		let request = FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields": "email, name, id"])
		let _ = request?.start() {(request, result, error) in
			print(result.debugDescription)
			callback()
		}
	}
	
	func setupLoginButton(_ button: FBSDKLoginButton) {
		button.readPermissions = ["public_profile", "email", "user_friends"]
	}
	
	private init() {
		NotificationCenter.default.addObserver(self, selector: #selector(accessTokenDidChange), name: NSNotification.Name.FBSDKAccessTokenDidChange, object: nil)
	}
	
	@objc private func accessTokenDidChange(notification: Notification) {
		print(notification)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}
