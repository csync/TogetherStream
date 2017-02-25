//
//  HomeViewModel.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 1/4/17.
//  Copyright © 2017 IBM. All rights reserved.
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
	
	/// Fetches all stream invites for the current user and updates the model.
	///
    /// - Parameter callback: The callback called on completion. Will return an error
    /// or the streams.
	func refreshStreams(callback: @escaping (Error?, [Stream]?) -> Void) {
		accountDataManager.retrieveInvites {[weak self] error, streams in
			if let error = error {
				callback(error, nil)
			}
			else {
				self?.streams = streams ?? []
				callback(nil, streams)
			}
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
}
