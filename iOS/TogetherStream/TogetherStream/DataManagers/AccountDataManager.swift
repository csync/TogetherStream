//
//  AccountDataManager.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 12/5/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation
import FBSDKLoginKit

/// Manages connections to the Together Stream server.
class AccountDataManager {
	/// Singleton object
	static let sharedInstance = AccountDataManager()
	
	// TODO: move to plist
    var serverAddress = "https://together-stream.mybluemix.net"
	/// Shorthand for shared URLSession
	private var urlSession = URLSession.shared
	/// Token that is used to authenticate requests to server
	private var _serverAccessToken: String?
	/// Gets server token and saves token on set
	private var serverAccessToken: String? {
		get {
			return _serverAccessToken
		}
		set {
			let userDefaults = UserDefaults()
			userDefaults.set(newValue, forKey: "server_access_token")
			userDefaults.synchronize()
			_serverAccessToken = newValue
		}
	}
	
    /// Sends an invite to the stream for the given users.
    ///
    /// - Parameters:
    ///   - stream: The stream the invite is for.
    ///   - users: The list of users to send the invite to.
    func sendInvite(for stream: Stream, to users: [User]) {
        // Build URL
		guard let serverAccessToken = serverAccessToken,
            let url = URL(string: serverAddress + "/invites?access_token=" + serverAccessToken),
            let userID = FacebookDataManager.sharedInstance.profile?.userID else {
                return
		}
        // Configure request
		let streamPath = "streams." + userID
		let host = FacebookDataManager.sharedInstance.profile?.name ?? ""
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = try? JSONSerialization.data(withJSONObject: ["host": host, "streamPath": streamPath, "users": users.map({$0.id}), "currentBadgeCount": UIApplication.shared.applicationIconBadgeNumber, "streamName": stream.name, "streamDescription": stream.description])
        
        // Status of request is not checked
		sendToServer(request: request){_,_,_ in}
	}
	
	/// Fetches all stream invites for the current user from server.
	///
	/// - Parameter callback: The callback called on completion.
	func retrieveInvites(callback: @escaping (Error?, [Stream]?) -> Void) {
        // Build URL
		guard let serverAccessToken = serverAccessToken,
            let url = URL(string: serverAddress + "/invites?access_token=" + serverAccessToken) else {
                callback(ServerError.invalidConfiguration, nil)
                return
		}
		sendToServer(request: URLRequest(url: url)) {data, response, error in
			if let error = error {
				callback(error, nil)
			}
			else {
				do {
                    // Serialize data into stream objects
					let jsonData = try JSONSerialization.jsonObject(with: data ?? Data()) as? [[String: Any]] ?? []
					var streams: [Stream] = []
					for streamData in jsonData {
						if let stream = Stream(jsonDictionary: streamData) {
							streams.append(stream)
						}
					}
					callback(nil, streams)
				}
				catch {
					callback(error, nil)
				}
			}
		}
	}
	
	/// Deletes the stream and all invites sent out by the signed in user
	func deleteInvites() {
		guard let serverAccessToken = serverAccessToken,
            let url = URL(string: serverAddress + "/invites?access_token=" + serverAccessToken) else {
                return
		}
		var request = URLRequest(url: url)
		request.httpMethod = "DELETE"
        
        // Status of request is not checked
		sendToServer(request: request){_,_,_ in}
	}
	
    /// Signs up for a Together Stream account by providing a valid Facebook Token
    /// If already signed up, this method just logs in the provided user
    ///
    /// - Parameters:
    ///   - accessToken: A valid Facebook access token provided by the Facebook SDK
    ///   - callback: The callback called on completion. A nil error means it was successful.
    func signup(withFacebookAccessToken accessToken: String, callback: @escaping (Error?) -> Void) {
        // Build URL
		guard let url = URL(string: serverAddress + "/auth/facebook/token/login") else {
            callback(ServerError.cannotFormURL)
			return
		}
        // Configure request
		var request = URLRequest(url: url)
		request.addValue(accessToken, forHTTPHeaderField: "access_token")
		let task = urlSession.dataTask(with: request) {data,response,error in
            guard error == nil else { callback(error); return }
            // Parse server access token from response query parameters
            guard let url = response?.url,
                let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
                let token = queryItems.first(where: {$0.name == "access_token"}) else {
                    callback(ServerError.unexpectedResponse)
                    return
            }
            self.serverAccessToken = token.value
            // Set the current device token for the signed in user
            self.postDeviceTokenToServer() {error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
            callback(nil)
		}
		task.resume()
	}
	
	private init() {
		_serverAccessToken = UserDefaults().string(forKey: "server_access_token")
	}
	
    /// Assigns the current device token to the logged in account
    ///
    /// - Parameter callback: The callback called on completion. A nil error means it was successful.
    private func postDeviceTokenToServer(callback: @escaping (Error?) -> Void) {
        guard let deviceToken = UserDefaults.standard.object(forKey: "deviceToken") as? String else {
            callback(ServerError.cannotGetDeviceToken)
            return
        }
		guard let serverAccessToken = serverAccessToken, let url = URL(string: serverAddress + "/invites/device-token?access_token=" + serverAccessToken) else {
            callback(ServerError.cannotFormURL)
			return
		}
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = try? JSONSerialization.data(withJSONObject: ["token": deviceToken])
		sendToServer(request: request){data, response, error in
            callback(error)
        }
		
	}
	
	/// Helper function to send authenticated request to server.
    /// Will refresh token if needed.
	///
	/// - Parameters:
	///   - request: The request to send.
	///   - callback: The callback to call on completeion. Contains complete response.
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
	
	/// Requests token to be refreshed from server and attempts to save new token.
	///
	/// - Parameter callback: The callback called on completion. A nil error means it was successful.
	private func refreshToken(withCallback callback: @escaping (Error?) -> Void) {
		guard let serverAccessToken = serverAccessToken,
            let url = URL(string: serverAddress + "/auth/refresh?access_token=" + serverAccessToken) else {
			callback(ServerError.cannotFormURL)
			return
		}
		let task = urlSession.dataTask(with: url) {data, response, error in
			guard let data = data, error == nil else {
				callback(error)
				return
			}
			guard let jsonData = try? JSONSerialization.jsonObject(with: data),
                let newServerAccessToken = (jsonData as? [String: String])?["access_token"] else {
                    callback(ServerError.unexpectedResponse)
                    return
            }
            self.serverAccessToken = newServerAccessToken
            callback(nil)
		}
		task.resume()
	}
}
