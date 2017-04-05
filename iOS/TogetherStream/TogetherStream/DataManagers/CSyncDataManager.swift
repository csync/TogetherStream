//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-ios
//

import Foundation
import CSyncSDK

/// Manages interacting with the the CSync server.
class CSyncDataManager {
    /// Singleton object
    static let sharedInstance = CSyncDataManager()
    
    /// Returns true if currently authenticated, false otherwise.
    var isAuthenticated: Bool {
        return app.authData != nil
    }
    
    /// The url of the CSync server.
    private let csyncURL = Utils.getStringValueWithKeyFromPlist("private", key: "csync_url") ?? ""
    /// The port of the CSync server.
    private let csyncPort = Utils.getIntValueWithKeyFromPlist("private", key: "csync_port") ?? -1
    /// The CSync application
    private lazy var app: App = { [unowned self] in
        return App(host: self.csyncURL, port: self.csyncPort, options: ["useSSL":"NO" as AnyObject, "dbInMemory":"YES" as AnyObject])
    }()
    
    /// Authenticates to the CSync server by using a facebook access token.
    ///
    /// - Parameters:
    ///   - fbAccessToken: The token to authenticate with.
    ///   - callback: The callback called on completion. Will return the auth data
    /// or an error.
    func authenticate(withFBAccessToken fbAccessToken: String, callback: @escaping (AuthData?, Error?) -> ()) {
        app.authenticate("facebook", token: fbAccessToken) {authData, error in
            callback(authData, error)
        }
    }

    /// Unauthenticates to CSync server
    ///
    /// - Parameter callback: The callback called on completion. A nil error means it was successful.
    func unauthenticate(callback: @escaping (Error?) -> ()) {
        app.unauth() {error in
            callback(error)
        }
    }
    
    /// Writes the given value to the provided key path. See Contextual Sync documentation
    /// for key path structure guidelines.
    ///
    /// - Parameters:
    ///   - value: The value to write.
    ///   - path: The path to write to.
    ///   - acl: Optional access control to set the key to. Defaults to public read.
    func write(_ value: String, toKeyPath path: String, withACL acl: ACL = .PublicRead) {
        let key = app.key(path)
        key.write(value, with: acl) { key, error in
            if let error = error {
                print(error)
            }
        }
    }
    
    /// Deletes the key at the given path. Supports wildcard characters.
    ///
    /// - Parameter path: The path of the key to delete.
    func deleteKey(atPath path: String) {
        let key = app.key(path)
        key.delete() {key, error in
            if let error = error {
                print(error)
            }
        }
    }
    
    /// Creates a key for the given path. Supports wildcard characters.
    ///
    /// - Parameter path: The path of the key.
    /// - Returns: The key at the given path.
    func createKey(atPath path: String) -> Key {
        return app.key(path)
    }
    
    private init(){}
}
