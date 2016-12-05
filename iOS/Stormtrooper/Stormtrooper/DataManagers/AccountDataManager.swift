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
	
	var profile: FBSDKProfile? {
		return FBSDKProfile.current() ?? nil
	}
	
	func setupLoginButton(_ button: FBSDKLoginButton) {
		button.readPermissions = ["public_profile", "email", "user_friends"]
	}
	
	private init() {
		NotificationCenter.default.addObserver(self, selector: #selector(accessTokenDidChange), name: NSNotification.Name.FBSDKAccessTokenDidChange, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(profileDidChange), name: NSNotification.Name.FBSDKProfileDidChange, object: nil)
	}
	
	@objc private func accessTokenDidChange(notification: Notification) {
		print(notification.userInfo)
	}
	
	@objc private func profileDidChange(notification: Notification) {
		print(notification.userInfo)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}
