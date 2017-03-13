//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-ios
//

import Foundation
import FBSDKLoginKit

/// Data manager that manages requests for Facebook.
class FacebookDataManager {
    /// Singleton object
    static let sharedInstance = FacebookDataManager()
    
    /// The user's Facebook profile if signed in.
    var profile: FBSDKProfile? {
        return FBSDKProfile.current() ?? nil
     }
    /// The user's Facebook access token if signed in.
    var accessToken: String? {
        return FBSDKAccessToken.current()?.tokenString
    }
    /// In-memory cached collection of retrieved users.
    /// Maps ids to User objects.
    var userCache: [String: User] = [:]
    
    /// Requested size of the users' profile pic.
    private let highResSize = CGSize(width:500, height:500)
    
    /// Shorthand for shared URLSession
    private let urlSession = URLSession.shared
    /// Shorthand for shared AccountDataManager
    private let accountDataManager = AccountDataManager.sharedInstance
    /// Shorthand for the CSyncDataManager
    private let csyncDataManager = CSyncDataManager.sharedInstance
    /// Maps queue identifer to a thread safe callback queue for retrieving a User.
    private var userCallbackQueues: [String: ThreadSafeCallbackQueue<User>] = [:]
    /// Serial queue for checking if a thread safe queue exists for a particular user.
    private let userCallbacksCheckingQueue = DispatchQueue(label: "user.checker")
    
    /// Configures a Facebook login button to be used.
    ///
    /// - Parameter button: The button to configure.
    func setupLoginButton(_ button: FBSDKLoginButton) {
        button.readPermissions = ["public_profile", "email", "user_friends"]
    }
    
    /// Logs out of the current Facebook account.
    func logOut() {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
    }
    
    /// Fetches all friends of the logged in user who are also
    /// using the app.
    ///
    /// - Parameter callback: The callback called on completion. Will return an error
    /// or the list of friends.
    func fetchFriends(callback: @escaping (Error?, [User]?) -> Void) {
        innerFetchFriends(withAfterCursor: nil, friends: [], callback: callback)
    }
    
    /// Fetches the profile picture of the logged in user. Does a fresh refresh on every call.
    ///
    /// - Parameter callback: The callback called on completion. Will return an error
    /// or the image.
    func fetchProfilePictureForCurrentUser(callback: @escaping (Error?, UIImage?) -> Void) {
        // Configure URL
        guard let profile = profile, let pictureURL = profile.imageURL(for: .square, size: highResSize) else {
            callback(ServerError.invalidConfiguration, nil)
            return
        }
        
        let task = urlSession.dataTask(with: pictureURL){data, response, error in
            guard error == nil else {
                callback(error, nil)
                return
            }
            // Parse response
            guard let data = data, let picture = UIImage(data: data) else {
                callback(ServerError.unexpectedResponse, nil)
                return
            }
            callback(nil, picture)
        }
        task.resume()
    }
    
    /// Fetches profile information for a given user. Will cache response in-memory to be served
    /// on future requests.
    ///
    /// - Parameters:
    ///   - id: The Facebook ID of the user to fetch.
    ///   - callback: The callback called on completion. Will return an error
    /// or the user.
    func fetchInfoForUser(withID id: String, callback: @escaping (Error?, User?) -> Void) {
        // Returns cached user if available
        if let user = userCache[id] {
            callback(nil, user)
            return
        }
        // Gets or creates the callback queue to fetch the current user
        let userInfoQueue = fetchOrCreateQueue(identifier: "user.\(id)")
        // Adds callback to queue and checks to see if the request is already in progress or has already succeeded
        let queueStatus = userInfoQueue.addCallbackAndCheckQueueStatus(callback: callback)
        if queueStatus.alreadySucceeded {
            // Request has succeeded since last cache check, user should be available now
            if let user = userCache[id] {
                callback(nil, user)
            }
            else {
                // Unexecpted failure, request is reported as succeeded but user is not found
                callback(ServerError.unexpectedQueueFail, nil)
            }
        }
        // If first in queue, make the request
        if queueStatus.wasEmpty
        {
            let parameters = ["fields": "name, picture.width(\(Int(highResSize.width))).height(\(Int(highResSize.height)))"]
            let request = FBSDKGraphRequest(graphPath: id, parameters: parameters)
            let _ = request?.start(){(request, result, error) in
                // Checks for failure, will notify all callbacks if failure occurs
                guard error == nil else {
                    userInfoQueue.executeAndClearCallbacks(withError: error, object: nil)
                    return
                }
                guard let result = result as? [String: Any] else {
                    userInfoQueue.executeAndClearCallbacks(withError: ServerError.unexpectedResponse, object: nil)
                    return
                }
                let user = User(facebookResponse: result)
                // Cache response
                self.userCache[id] = user
                // Notify all callbacks that the user has been fetched
                userInfoQueue.executeAndClearCallbacks(withError: nil, object: user)
            }
        }
        
    }
    
    private init() {
        // Methods for when access token and profile changes
        //NotificationCenter.default.addObserver(self, selector: #selector(accessTokenDidChange), name: NSNotification.Name.FBSDKAccessTokenDidChange, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(profileDidChange), name: NSNotification.Name.FBSDKProfileDidChange, object: nil)
        // Will authenticate CSync account as soon as possible. Authentication must complete before requests to CSync can be made
        if let accessToken = FBSDKAccessToken.current() {
            csyncDataManager.authenticate(withFBAccessToken: accessToken.tokenString) {authData, error in
                if let error = error {
                    print(error)
                }
            }
        }
    }
    
    deinit {
        // Cleanup if using observers above
        //NotificationCenter.default.removeObserver(self)
    }
    
    /// Helper function to recursively traverse friends pages to retrieve all friends
    ///
    /// - Parameters:
    ///   - afterCursor: The cursor that points to the end of the page of data that has been returned.
    ///   - friends: List of currently retrieved friends.
    ///   - callback: The callback to be called on completion.
    private func innerFetchFriends(withAfterCursor afterCursor: String?, friends: [User], callback: @escaping (Error?, [User]?) -> Void) {
        // Copy parameters to be able to mutate
        var afterCursor = afterCursor
        var friends = friends
        
        var parameters = ["fields": "friends{name, picture.width(\(Int(highResSize.width))).height(\(Int(highResSize.height)))}"]
        if let afterCursor = afterCursor {
            // Retrieve the next page
            parameters["after"] = afterCursor
        }
        let request = FBSDKGraphRequest(graphPath: "me", parameters: parameters)
        let _ = request?.start(){(request, result, error) in
            guard error == nil else {
                callback(error,nil)
                return
            }
            // Parse response
            let friendsResult = (result as? [String: Any])?["friends"] as? [String: Any]
            guard let friendsPage = friendsResult?["data"] as? [[String: Any]] else {
                return
            }
            for friend in friendsPage {
                let user = User(facebookResponse: friend)
                friends.append(user)
                // Cache user to be able to fetch later
                self.userCache[user.id] = user
            }
            // Check if there's another page to fetch
            let paging = friendsResult?["paging"] as? [String: Any]
            if paging?["next"] != nil {
                let cursors = paging?["cursors"] as? [String: String]
                afterCursor = cursors?["after"]
            }
            if afterCursor != nil {
                // Fetch next page
                self.innerFetchFriends(withAfterCursor: afterCursor, friends: friends, callback: callback)
            }
            else {
                // Sort friends alphabetically
                let sortedFriends = friends.sorted(by: {return $0.name < $1.name})
                callback(nil, sortedFriends)
            }
        }
    }
    
    /// Returns the callback queue the given identifer, creating it if necessary.
    /// This method is thread safe.
    ///
    /// - Parameter identifier: The identifier of the queue.
    /// - Returns: The callback queue for fetching a user.
    private func fetchOrCreateQueue(identifier: String) -> ThreadSafeCallbackQueue<User> {
        var threadSafeQueue = ThreadSafeCallbackQueue<User>(identifier: "")
        // Synchronously check if queue exists
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
