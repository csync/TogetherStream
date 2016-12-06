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
	
	// TODO: move to plist
	private var serverAddress = "https://stormtrooper.mybluemix.net"
	private var urlSession = URLSession.shared
	private var serverAccessToken: String?
	
	func setupLoginButton(_ button: FBSDKLoginButton) {
		button.readPermissions = ["public_profile", "email", "user_friends"]
	}
	
	private init() {
		NotificationCenter.default.addObserver(self, selector: #selector(accessTokenDidChange), name: NSNotification.Name.FBSDKAccessTokenDidChange, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(profileDidChange), name: NSNotification.Name.FBSDKProfileDidChange, object: nil)
	}
	
	private func signup(withAccessToken accessToken: String) {
		guard let url = URL(string: serverAddress + "/auth/facebook/token/login") else {
			return
		}
		var request = URLRequest(url: url)
		request.addValue(accessToken, forHTTPHeaderField: "access_token")
		let task = urlSession.dataTask(with: request) {data,response,error in
			if let url = response?.url {
				let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
				let token = queryItems?.first(where: {$0.name == "access_token"})
				self.serverAccessToken = token?.value
				self.postDeviceTokenToServer()
			}
		}
		task.resume()
	}
	
	private func postDeviceTokenToServer() {
		guard let serverAccessToken = serverAccessToken, let deviceToken = UserDefaults.standard.object(forKey: "deviceToken") as? String, let url = URL(string: serverAddress + "/notifications/device-token?access_token=" + serverAccessToken) else {
			return
		}
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = try? JSONSerialization.data(withJSONObject: ["token": deviceToken])
		let task = urlSession.dataTask(with: request) {data,response,error in
			
		}
		task.resume()
		
	}
	
	@objc private func accessTokenDidChange(notification: Notification) {
		if let accessToken = FBSDKAccessToken.current() {
			signup(withAccessToken: accessToken.tokenString)
		}
	}
	
	@objc private func profileDidChange(notification: Notification) {
		print(notification.userInfo)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}
