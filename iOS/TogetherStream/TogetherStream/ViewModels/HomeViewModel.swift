//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-ios
//

import UIKit
import Foundation

/// View model for the "Home/Stream Invites" screen.
class HomeViewModel {
    /// The streams that the user has been invited to.
    var streams: [Stream] = []
    
    /// The number of rows that should be displayed.
    var numberOfRows: Int {
        return streams.count + 1
    }
    
    /// Shorthand for the shared AccountDataManager.
    private let accountDataManager = AccountDataManager.sharedInstance
    /// Shorthand for the shared YouTubeDataManager.
    private let youtubeDataManager = YouTubeDataManager.sharedInstance
    /// Shorthand for the shared CSyncDataManager.
    private let csyncDataManager = CSyncDataManager.sharedInstance
    /// Shorthand for the shared CSyncDataManager.
    private let facebookDataManager = FacebookDataManager.sharedInstance
    
    /// First make sure that the user is authenticated, then fetches all stream invites for the 
    /// current user and updates the model.
    ///
    /// - Parameter callback: The callback called on completion. Will return an error
    /// or the streams.
    func refreshStreams(callback: @escaping (Error?, [Stream]?) -> Void) {
        guard let accessToken = facebookDataManager.accessToken else {
            callback(ServerError.invalidConfiguration, nil)
            return
        }
        if !csyncDataManager.isAuthenticated {
            csyncDataManager.authenticate(withFBAccessToken: accessToken) {authData, error in
                guard error == nil else {
                    callback(error, nil)
                    return
                }
                self.retrieveInvites(callback: callback)
            }
        }
        else {
            retrieveInvites(callback: callback)
        }
        
    }
    
    /// Returns whether the cell at the given index path should
    /// be selectable.
    ///
    /// - Parameter indexPath: The index path that was selected.
    /// - Returns: Whether the given index path should be selectable.
    func shouldSelectCell(at indexPath: IndexPath) -> Bool {
        return indexPath.row < streams.count
    }
    
    /// Stops all streams from listening to current video changes.
    func stopStreamsListening() {
        for stream in streams {
            stream.stopListeningForCurrentVideo()
        }
    }
    
    /// Fetches the video for the given id.
    ///
    /// - Parameters:
    ///   - id: The id of the video.
    ///   - callback: The callback called on completion. Will return an error
    /// or the video.
    func fetchVideo(withID id: String, callback: @escaping (Error?, Video?) -> Void) {
        youtubeDataManager.fetchVideo(withID: id, callback: callback)
    }
    
    /// Clears the current user's stream and resets it to an inactive state.
    func resetCurrentUserStream() {
        if let username = FacebookDataManager.sharedInstance.profile?.userID {
            // Reset stream
            CSyncDataManager.sharedInstance.deleteKey(atPath: "streams.\(username).*.*")
            CSyncDataManager.sharedInstance.deleteKey(atPath: "streams.\(username).*")
            // Set empty state
            CSyncDataManager.sharedInstance.write("false", toKeyPath: "streams.\(username).isPlaying")
            CSyncDataManager.sharedInstance.write("false", toKeyPath: "streams.\(username).isActive")
            AccountDataManager.sharedInstance.deleteInvites()
        }
    }
    
    /// Fetches all stream invites for the current user and updates the model.
    ///
    /// - Parameter callback: The callback called on completion. Will return an error
    /// or the streams.
    private func retrieveInvites(callback: @escaping (Error?, [Stream]?) -> Void) {
        accountDataManager.retrieveInvites {[weak self] error, streams in
            if let error = error {
                callback(error, nil)
            }
            else {
                let streamBotStream = Stream(name: "Stream On", csyncPath: "streams.bot123", description: "Stream until your dreams come true—a fun mix of the internet’s best videos", hostFacebookID: "100016088973890")
                var fullStreams = streams ?? []
                fullStreams.append(streamBotStream)
                self?.streams = fullStreams
                callback(nil, streams)
            }
        }
    }
}
