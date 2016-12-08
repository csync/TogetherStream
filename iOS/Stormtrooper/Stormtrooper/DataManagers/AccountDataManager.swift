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
	
	func fetchFacebookFriends(callback: @escaping (Error?, [User]?) -> Void) {
		innerFetchFacebookFriends(withAfterCursor: nil, friends: [], callback: callback)
	}
	
	func sendInvite(forRoom room: String, to users: [User]) {
		guard let serverAccessToken = serverAccessToken, let url = URL(string: serverAddress + "/notifications?access_token=" + serverAccessToken) else {
			return
		}
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = try? JSONSerialization.data(withJSONObject: ["room": room, "users": users.map({$0.id})])
		sendToServer(request: request){_,_,_ in}
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
		sendToServer(request: request){_,_,_ in}
		
	}
	
	private func innerFetchFacebookFriends(withAfterCursor afterCursor: String?, friends: [User], callback: @escaping (Error?, [User]?) -> Void) {
		var afterCursor = afterCursor
		var friends = friends
		var parameters = ["fields": "friends"]
		if let afterCursor = afterCursor {
			parameters["after"] = afterCursor
		}
		let request = FBSDKGraphRequest(graphPath: "me", parameters: parameters)
		let _ = request?.start(){ (request, result, error) in
			if error != nil {
				callback(error,nil)
			}
			else {
				let friendsResult = (result as? [String: Any])?["friends"] as? [String: Any]
				guard let friendsPage = friendsResult?["data"] as? [[String: String]] else {
					return
				}
				for friend in friendsPage {
					friends.append(User(id: friend["id"] ?? "", name: friend["name"] ?? ""))
				}
				let paging = friendsResult?["paging"] as? [String: Any]
				if paging?["next"] != nil {
					let cursors = paging?["cursors"] as? [String: String]
					afterCursor = cursors?["after"]
				}
				if afterCursor != nil {
					self.innerFetchFacebookFriends(withAfterCursor: afterCursor, friends: friends, callback: callback)
				}
				else {
					callback(nil, friends)
				}
			}
		}
	}
	
	private func sendToServer(request: URLRequest, withCallback callback: @escaping (Data?, URLResponse?, Error?) -> Void) {
		let task = urlSession.dataTask(with: request) {data,response,error in
			guard let httpResponse = response as? HTTPURLResponse else {
				// Not HTTP Request, just pass through
				callback(data, response, error)
				return
			}
			if httpResponse.statusCode == 401 {
				//attempt to refresh token
				self.refreshToken() {error in
					if error != nil {
						callback(nil, nil, error)
					}
					else {
						self.sendToServer(request: request, withCallback: callback)
					}
				}
			}
			else {
				callback(data, response, error)
			}
		}
		task.resume()
	}
	
	private func refreshToken(withCallback callback: @escaping (Error?) -> Void) {
		guard let serverAccessToken = serverAccessToken, let url = URL(string: serverAddress + "/auth/refresh?access_token=" + serverAccessToken) else {
			callback(ServerError.cannotFormURL)
			return
		}
		let task = urlSession.dataTask(with: url) {data, response, error in
			guard let data = data, error != nil else {
				callback(error)
				return
			}
			let jsonData = try? JSONSerialization.jsonObject(with: data)
			if let newServerAccessToken = (jsonData as? [String: String])?["access_token"] {
				self.serverAccessToken = newServerAccessToken
				callback(nil)
			}
			else {
				callback(ServerError.unexpectedResponse)
			}
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
	
	enum ServerError: Error {
		case cannotFormURL, unexpectedResponse
	}
}
