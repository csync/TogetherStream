//
//  StreamViewModel.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 12/21/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation
import CSyncSDK

/// Delegate protocol for receiving updates to the model.
protocol StreamViewModelDelegate: class {
	func userCountChanged(toCount count: Int)
	func received(message: Message, for position: Int) -> Void
    func removedMessage(at position: Int) -> Void
	func receivedUpdate(forCurrentVideoID currentVideoID: String) -> Void
	func receivedUpdate(forIsPlaying isPlaying: Bool) -> Void
	func receivedUpdate(forIsBuffering isBuffering: Bool) -> Void
	func receivedUpdate(forPlaytime playtime: Float) -> Void
    func receivedVideoReport() -> Void
	func streamEnded() -> Void
}

/// View model for the "Stream" screen.
class StreamViewModel {
	
	/// An optional view model delegate.
	weak var delegate: StreamViewModelDelegate?
	
    /// The current stream. On set, perform setup.
    var stream: Stream? {
        didSet {
            if stream != nil {
                setupStream()
            }
        }
    }
    
    /// The queue of videos to play.
    var videoQueue: [Video]?
    /// The index of the currently playing video.
    var currentVideoIndex: Int?
	
	/// The number of users in the stream.
	var userCount: Int {
		return currentUserIDs.count
	}
    
    /// Whether the current user is the host of the stream.
    var isHost: Bool {
        return FacebookDataManager.sharedInstance.profile?.userID == stream?.hostFacebookID
    }
    
    /// The maximum amount of time the participant video can be desynced from the
    /// host, in seconds.
    let maximumDesyncTime: Float = 3.0
    
    /// Whether the host has no videos in their queue.
    var hostPlayerIsEmpty = true
	
	/// The messages that should be displayed.
	fileprivate(set) var messages: [Message] = []
	/// Whether the host is currently playing a video.
	fileprivate(set) var hostPlaying = false
    
    /// The maximum amount of chat messages that are stored and displayed.
    private let maximumChatMessages = 50
    
	/// The key of the stream for participants to listen for updates on.
	private var streamKey: Key?
    /// The key for the host to listen for reports of the video.
    private var reportedKey: Key?
	/// Shorthand for the shared CSyncDataManager.
	private var cSyncDataManager = CSyncDataManager.sharedInstance
    /// Shorthand for the shared FacebookDataManager.
    private var facebookDataManager = FacebookDataManager.sharedInstance
	/// Manager of sending and receiving heart beats.
	private var heartbeatDataManager: HeartbeatDataManager?
	/// Manager of sending and receiving chat messages.
	private var chatDataManager: ChatDataManager?
	/// Manager of sending and receiving participant messages.
	private var participantsDataManager: ParticipantsDataManager?
	/// The user IDs of the current users in the stream.
	private var currentUserIDs: Set<String> = []
    /// The CSync path of the stream, unwrapped here for convenience.
    private var csyncPath: String {
        return stream?.csyncPath ?? ""
    }
    
    /// Sets up the stream and data managers depending on if the user is the host.
    private func setupStream() {
        if !isHost {
            setupParticipant()
        }
        else {
            setupHost()
        }
        
        setupMessagesDataManagers()
        setupHeartbeatDataManager()
    }
	
	deinit {
		streamKey?.unlisten()
		if isHost {
			endStream()
            NotificationCenter.default.removeObserver(self)
		}
	}
    
    /// Deletes the comment provided.
    ///
    /// - Parameter comment: The comment to delete.
    func delete(comment: Message) {
        guard let comment = comment as? ChatMessage else {
            return
        }
        cSyncDataManager.deleteKey(atPath: comment.csyncPath)
    }
    
    /// Blocks the subject of the message provided.
    ///
    /// - Parameters:
    ///   - message: The message whos subject will be blocked.
    ///   - callback: Closure called on completion. A nil error means it was successful.
    func blockSubject(of message: Message, callback: ((Error?) -> Void)? = nil) {
        AccountDataManager.sharedInstance.sendBlock(forUserID: message.subjectID, callback: callback)
    }
    
    /// Fetches the video for the given id.
    ///
    /// - Parameters:
    ///   - id: The id of the video.
    ///   - callback: The callback called on completion. Will return an error
    /// or the video.
    func fetchVideo(withID id: String, callback: @escaping (Error?, Video?) -> Void) {
        YouTubeDataManager.sharedInstance.fetchVideo(withID: id, callback: callback)
    }
	
	/// Sends the given chat message.
	///
	/// - Parameter chatMessage: The message to send.
	func send(chatMessage: String) {
		chatDataManager?.send(message: chatMessage)
	}
	
	/// Sends the given play time.
	///
	/// - Parameter currentPlayTime: The play time to send.
	func send(currentPlayTime: Float) {
		cSyncDataManager.write(String(currentPlayTime), toKeyPath: "\(csyncPath).playTime")
	}
	
	/// Sends the given play state.
	///
	/// - Parameter playState: The play state to send.
	func send(playState: Bool) {
		let stateMessage = playState ? "true" : "false"
		cSyncDataManager.write(stateMessage, toKeyPath: "\(csyncPath).isPlaying")
	}
	
	/// Sends the given buffering state.
	///
	/// - Parameter isBuffering: The buffering state to send.
	func send(isBuffering: Bool) {
		let stateMessage = isBuffering ? "true" : "false"
		cSyncDataManager.write(stateMessage, toKeyPath: "\(csyncPath).isBuffering")
	}
	
	/// Sends the given video ID.
	///
	/// - Parameter currentVideoID: The video ID to send.
	func send(currentVideoID: String) {
		cSyncDataManager.write(currentVideoID, toKeyPath: "\(csyncPath).currentVideoID")
	}
    
    /// Sends to host that the video was reported.
    func reportVideo() {
        cSyncDataManager.write("true", toKeyPath: "\(csyncPath).isReported")
    }
	
	/// Ends and resets the stream.
	func endStream() {
        // Reset stream
        cSyncDataManager.deleteKey(atPath: csyncPath + ".*.*")
        cSyncDataManager.deleteKey(atPath: csyncPath + ".*")
        // Set empty state
        cSyncDataManager.write("false", toKeyPath: "\(csyncPath).isPlaying")
		cSyncDataManager.write("false", toKeyPath: "\(csyncPath).isActive")
        // Delete invites
        AccountDataManager.sharedInstance.deleteInvites()
	}
    
    /// Sends that the participant with the given ID either left or
    /// joined the stream.
    ///
    /// - Parameters:
    ///   - participantID: The ID of the participant.
    ///   - isJoining: Whether the participant left or joined.
    private func send(participantID: String, isJoining: Bool) {
        participantsDataManager?.send(participantID: participantID, isJoining: isJoining)
    }
	
	/// Sets up the stream as the host.
	private func setupHost() {
		// Create node so others can listen to it
		cSyncDataManager.write("", toKeyPath: csyncPath)
		// Creat heartbeat node so others can create in it
		cSyncDataManager.write("", toKeyPath: csyncPath + ".heartbeat", withACL: .PublicReadCreate)
		// Creat chat node so others can create in it
		cSyncDataManager.write("", toKeyPath: csyncPath + ".chat", withACL: .PublicReadCreate)
		// Set stream to active
		cSyncDataManager.write("true", toKeyPath: csyncPath + ".isActive")
        // Set video to unreported
        cSyncDataManager.write("false", toKeyPath: csyncPath + ".isReported", withACL: .PublicReadWrite)
        // Set state of inital video
        send(playState: false)
        
        // Set up reported video listner
        reportedKey = cSyncDataManager.createKey(atPath: csyncPath + ".isReported")
        reportedKey?.listen {[weak self] value, error in
            // Ensure view model still exists, there's no error. the
            // value still exists, and the video is reported.
            guard let `self` = self,
                let value = value,
                value.exists, value.data == "true" else {
                    return
            }
            self.delegate?.receivedVideoReport()
            self.cSyncDataManager.write("false", toKeyPath: self.csyncPath + ".isReported", withACL: .PublicReadWrite)
        }
		
		NotificationCenter.default.addObserver(self,
		                                       selector: #selector(receivedWillTerminateNotification),
		                                       name: NSNotification.Name.UIApplicationWillTerminate,
		                                       object: nil)
	}
	
	/// Sets up the stream as the participant.
	private func setupParticipant() {
		streamKey = cSyncDataManager.createKey(atPath: csyncPath + ".*")
        // Listen for changes on the stream
		streamKey?.listen() {[weak self] value, error in
            // Ensure view model still exists, there's no error and the
            // value still exists.
            guard let `self` = self,
                let value = value,
                value.exists else {
                    return
            }
            
            // Inform delegate of state change
            switch value.key.components(separatedBy: ".").last ?? "" {
            case "currentVideoID":
                if let id = value.data {
                    self.delegate?.receivedUpdate(forCurrentVideoID: id)
                }
            case "isPlaying" where value.data == "true":
                self.hostPlaying = true
                self.delegate?.receivedUpdate(forIsPlaying: true)
            case "isPlaying" where value.data == "false":
                self.hostPlaying = false
                self.delegate?.receivedUpdate(forIsPlaying: false)
            case "isBuffering" where value.data == "true":
                self.delegate?.receivedUpdate(forIsBuffering: true)
            case "isBuffering" where value.data == "false":
                self.delegate?.receivedUpdate(forIsBuffering: false)
            case "playTime":
                if let playtime = Float(value.data ?? "") {
                    self.delegate?.receivedUpdate(forPlaytime: playtime)
                }
            case "isActive" where value.data == "false":
                self.delegate?.streamEnded()
            default:
                break
            }
        }
	}
    
    /// Sets up the chat and participant data managers.
    private func setupMessagesDataManagers() {
        let userID = facebookDataManager.profile?.userID ?? ""
        
        let messageCallback: (Message) -> Void = {[unowned self] message in
            // insert on main queue to avoid table datasource corruption
            DispatchQueue.main.async {
                while self.messages.count >= self.maximumChatMessages {
                    self.messages.remove(at: 0)
                    self.delegate?.removedMessage(at: 0)
                }
                let position = self.insertIntoMessages(message)
                self.delegate?.received(message: message, for: position)
            }
        }
        
        let deleteMessageCallback: (String) -> Void = {[unowned self] deletedPath in
            for (index, message) in self.messages.enumerated() {
                if let message = message as? ChatMessage, message.csyncPath == deletedPath {
                    // delete on main queue to avoid table datasource corruption
                    DispatchQueue.main.async {
                        self.messages.remove(at: index)
                        self.delegate?.removedMessage(at: index)
                    }
                    break
                }
            }
        }
        
        chatDataManager = ChatDataManager(streamPath: csyncPath, id: userID)
        chatDataManager?.didReceiveMessage = messageCallback
        chatDataManager?.didReceiveDeletedMessageAtPath = deleteMessageCallback
        
        participantsDataManager = ParticipantsDataManager(streamPath: csyncPath)
        participantsDataManager?.didReceiveMessage = messageCallback
    }
    
    /// Sets up the heartbeat data manager.
    private func setupHeartbeatDataManager() {
        let userID = facebookDataManager.profile?.userID ?? ""
        
        heartbeatDataManager = HeartbeatDataManager(streamPath: csyncPath, id: userID)
        heartbeatDataManager?.didReceiveHeartbeats = {[unowned self] heartbeats in
            let changedUsers = self.currentUserIDs.symmetricDifference(heartbeats)
            self.currentUserIDs = heartbeats
            self.delegate?.userCountChanged(toCount: self.userCount)
            for userID in changedUsers {
                if self.isHost {
                    Utils.sendGoogleAnalyticsEvent(withCategory: "Stream",
                                                   action: "UserCountChange",
                                                   label: heartbeats.contains(userID) ? "Joining" : "Leaving",
                                                   value: self.userCount as NSNumber)
                    if heartbeats.contains(userID) {
                        self.send(participantID: userID, isJoining: true)
                    }
                    else {
                        self.send(participantID: userID, isJoining: false)
                    }
                }
                else if userID == self.stream?.hostFacebookID && !heartbeats.contains(userID) {
                    //self.delegate?.streamEnded()
                }
            }
        }
    }
	
	/// On app terminating, try to end the stream as the host.
	///
	/// - Parameter notification: The notification of termination.
	@objc private func receivedWillTerminateNotification(_ notification: Notification) {
		endStream()
	}
	
	/// Insert the given message into the messages object, sorted by timestamp.
	///
    /// - complexity: O(log(n)) of `messages` length
	/// - Parameter message: The message to insert.
	/// - Returns: The position the messages was inserted in.
	private func insertIntoMessages(_ message: Message) -> Int {
		if messages.isEmpty {
			messages.append(message)
			return 0
		}
        // Binary search for insertion point
		let timestamp = message.timestamp
		var lowIndex = 0
		var highIndex = messages.count
		while lowIndex < highIndex {
			let midIndex = (lowIndex + highIndex) / 2
			let midTimestamp = messages[midIndex].timestamp
			if midTimestamp < timestamp {
				lowIndex = midIndex + 1
			}
			else if midTimestamp > timestamp {
				highIndex = midIndex
			}
			else {
				// rare case where time is exactly the same
				messages.insert(message, at: midIndex + 1)
				return midIndex + 1
			}
		}
		messages.insert(message, at: highIndex)
		return highIndex
	}
}
