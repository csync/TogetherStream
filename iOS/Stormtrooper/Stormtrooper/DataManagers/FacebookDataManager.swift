//
//  FacebookDataManager.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 12/9/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation
import FBSDKLoginKit

class FacebookDataManager {
    static let sharedInstance = FacebookDataManager()

    let highResSize = CGSize(width:500, height:500)
	
	var profile: FBSDKProfile? {
		return FBSDKProfile.current() ?? nil
	 }
    var cachedFriendIds: [String] = []
    var userCache: [String: User] = [:]
	
	private let urlSession = URLSession.shared
	private let accountDataManager = AccountDataManager.sharedInstance
	private let csyncDataManager = CSyncDataManager.sharedInstance
    private var userCallbackQueues: [String: ThreadSafeCallbackQueue<User>] = [:]
    private let userCallbacksCheckingQueue = DispatchQueue(label: "user.checker")
	
	func setupLoginButton(_ button: FBSDKLoginButton) {
		button.readPermissions = ["public_profile", "email", "user_friends"]
	}
    
    func logOut() {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        FBSDKProfile.setCurrent(nil)
    }
	
	func fetchFriends(callback: @escaping (Error?, [User]?) -> Void) {
		innerFetchFriends(withAfterCursor: nil, friends: [], callback: callback)
	}
	
	func fetchProfilePictureForCurrentUser(callback: @escaping (Error?, UIImage?) -> Void) {
		guard let profile = profile, let pictureURL = profile.imageURL(for: .square, size: highResSize) else {
			callback(ServerError.invalidConfiguration, nil)
			return
		}
		
		let task = urlSession.dataTask(with: pictureURL){data, response, error in
			guard error == nil else {
				callback(error, nil)
				return
			}
			guard let data = data, let picture = UIImage(data: data) else {
				callback(ServerError.unexpectedResponse, nil)
				return
			}
			callback(nil, picture)
		}
		task.resume()
	}
	
	func fetchInfoForUser(withID id: String, callback: @escaping (Error?, User?) -> Void) {
		if let user = userCache[id] {
			callback(nil, user)
            return
		}
        let userInfoQueue = fetchOrCreateQueue(identifier: "user.\(id)")
        let queueStatus = userInfoQueue.addCallbackAndCheckQueueStatus(callback: callback)
        if queueStatus.alreadySucceeded {
            if let user = userCache[id] {
                callback(nil, user)
            }
            else {
                callback(ServerError.unexpectedQueueFail, nil)
            }
        }
        if queueStatus.didAddFirst
        {
            let parameters = ["fields": "name, picture.width(\(Int(highResSize.width))).height(\(Int(highResSize.height)))"]
            let request = FBSDKGraphRequest(graphPath: id, parameters: parameters)
            let _ = request?.start(){(request, result, error) in
                guard error == nil else {
                    userInfoQueue.executeAndClearCallbacks(withError: error, object: nil)
                    return
                }
                guard let result = result as? [String: Any] else {
                    userInfoQueue.executeAndClearCallbacks(withError: ServerError.unexpectedResponse, object: nil)
                    return
                }
                let user = User(facebookResponse: result)
                self.userCache[id] = user
                userInfoQueue.executeAndClearCallbacks(withError: nil, object: user)
            }
        }
		
	}
	
	private init() {
		NotificationCenter.default.addObserver(self, selector: #selector(accessTokenDidChange), name: NSNotification.Name.FBSDKAccessTokenDidChange, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(profileDidChange), name: NSNotification.Name.FBSDKProfileDidChange, object: nil)
		
		if let profile = profile {
			csyncDataManager.authenticate(withID: profile.userID)
		}
	}
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
	
	
	@objc private func accessTokenDidChange(notification: Notification) {
		if let accessToken = FBSDKAccessToken.current() {
			accountDataManager.signup(withFacebookAccessToken: accessToken.tokenString)
		}
	}
	
	@objc private func profileDidChange(notification: Notification) {
		if let profile = profile {
			csyncDataManager.authenticate(withID: profile.userID)
		}
	}
	
	private func innerFetchFriends(withAfterCursor afterCursor: String?, friends: [User], callback: @escaping (Error?, [User]?) -> Void) {
		var afterCursor = afterCursor
		var friends = friends
		var parameters = ["fields": "friends{name, picture.width(\(Int(highResSize.width))).height(\(Int(highResSize.height)))}"]
		if let afterCursor = afterCursor {
			parameters["after"] = afterCursor
		}
		let request = FBSDKGraphRequest(graphPath: "me", parameters: parameters)
		let _ = request?.start(){(request, result, error) in
			guard error == nil else {
				callback(error,nil)
                return
			}
            let friendsResult = (result as? [String: Any])?["friends"] as? [String: Any]
            guard let friendsPage = friendsResult?["data"] as? [[String: Any]] else {
                return
            }
            for friend in friendsPage {
                let user = User(facebookResponse: friend)
                friends.append(user)
                self.userCache[user.id] = user
            }
            let paging = friendsResult?["paging"] as? [String: Any]
            if paging?["next"] != nil {
                let cursors = paging?["cursors"] as? [String: String]
                afterCursor = cursors?["after"]
            }
            if afterCursor != nil {
                self.innerFetchFriends(withAfterCursor: afterCursor, friends: friends, callback: callback)
            }
            else {
                let sortedFriends = friends.sorted(by: {return $0.name < $1.name})
                self.cachedFriendIds = sortedFriends.map({return $0.id})
                callback(nil, sortedFriends)
            }
		}
	}
    
    private func fetchOrCreateQueue(identifier: String) -> ThreadSafeCallbackQueue<User> {
        var threadSafeQueue = ThreadSafeCallbackQueue<User>(identifier: "")
        userCallbacksCheckingQueue.sync {
            if let queue = userCallbackQueues[identifier] {
                threadSafeQueue = queue
            }
            else {
                threadSafeQueue = ThreadSafeCallbackQueue<User>(identifier: identifier)
                userCallbackQueues[identifier] = threadSafeQueue
            }
        }
        return threadSafeQueue
    }
}
