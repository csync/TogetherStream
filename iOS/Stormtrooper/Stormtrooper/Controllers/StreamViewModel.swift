//
//  StreamViewModel.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 12/21/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation
import CSyncSDK

protocol StreamViewModelDelegate: class {
	func userCountChanged(toCount count: Int)
	func received(message: Message, for position: Int) -> Void
    func removedOldestMessage() -> Void
	func receivedUpdate(forCurrentVideoID currentVideoID: String) -> Void
	func receivedUpdate(forIsPlaying isPlaying: Bool) -> Void
	func receivedUpdate(forIsBuffering isBuffering: Bool) -> Void
	func receivedUpdate(forPlaytime playtime: Float) -> Void
	func streamEnded() -> Void
}

class StreamViewModel {
	
	weak var delegate: StreamViewModelDelegate?
	
    var stream: Stream? {
        didSet {
            if stream != nil {
                setupStreams()
            }
        }
    }
    
    var videoQueue: [Video]? {
        didSet {
            // Set inital video
            if videoQueue?.count ?? 0 > 0, let firstVideo = videoQueue?[0] {
                send(currentVideoID: firstVideo.id)
            }
        }
    }
    var currentVideoIndex: Int?
	
	var userCount: Int {
		return currentUserIDs.count
	}
    
    var csyncPath: String {
        return stream?.csyncPath ?? ""
    }
    
    let maximumDesyncTime: Float = 3.0
    
    private let maximumChatMessages = 50
	
	fileprivate(set) var messages: [Message] = []
	fileprivate(set) var hostPlaying = false
	var isHost: Bool {
		return FacebookDataManager.sharedInstance.profile?.userID == stream?.hostFacebookID
	}
    
	private var listenerKey: Key?
	private var cSyncDataManager = CSyncDataManager.sharedInstance
	private var heartbeatDataManager: HeartbeatDataManager?
	private var chatDataManager: ChatDataManager?
	private var participantsDataManager: ParticipantsDataManager?
	private var currentUserIDs: Set<String> = []
    
    private func setupStreams() {
        if !isHost {
            setupParticipant()
        }
        else {
            setupHost()
        }
        
        let userID = FacebookDataManager.sharedInstance.profile?.userID ?? ""
        
        let messageCallback: (Message) -> Void = {[unowned self] message in
            // insert on main queue to avoid table datasource corruption
            DispatchQueue.main.async {
                while self.messages.count >= self.maximumChatMessages {
                    self.messages.remove(at: 0)
                    self.delegate?.removedOldestMessage()
                }
                let position = self.insertIntoMessages(message)
                self.delegate?.received(message: message, for: position)
            }
        }
        
        chatDataManager = ChatDataManager(streamPath: csyncPath, id: FacebookDataManager.sharedInstance.profile?.userID ?? "")
        chatDataManager?.didReceiveMessage = messageCallback
        
        participantsDataManager = ParticipantsDataManager(streamPath: csyncPath)
        participantsDataManager?.didReceiveMessage = messageCallback
        
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
	
	deinit {
		listenerKey?.unlisten()
		if isHost {
			endStream()
		}
	}
    
    func fetchVideo(withID id: String, callback: @escaping (Error?, Video?) -> Void) {
        YouTubeDataManager.sharedInstance.fetchVideo(withID: id, callback: callback)
    }
	
	func send(chatMessage: String) {
		chatDataManager?.send(message: chatMessage)
	}
	
	func send(participantID: String, isJoining: Bool) {
		participantsDataManager?.send(participantID: participantID, isJoining: isJoining)
	}
	
	func send(currentPlayTime: Float) {
		cSyncDataManager.write(String(currentPlayTime), toKeyPath: "\(csyncPath).playTime")
	}
	
	func send(playState: Bool) {
		let stateMessage = playState ? "true" : "false"
		cSyncDataManager.write(stateMessage, toKeyPath: "\(csyncPath).isPlaying")
	}
	
	func send(isBuffering: Bool) {
		let stateMessage = isBuffering ? "true" : "false"
		cSyncDataManager.write(stateMessage, toKeyPath: "\(csyncPath).isBuffering")
	}
	
	func send(currentVideoID: String) {
		cSyncDataManager.write(currentVideoID, toKeyPath: "\(csyncPath).currentVideoID")
	}
	
	func endStream() {
        // Reset stream
        cSyncDataManager.deleteKey(atPath: csyncPath + ".*.*")
        cSyncDataManager.deleteKey(atPath: csyncPath + ".*")
        // Set empty state
        cSyncDataManager.write("false", toKeyPath: "\(csyncPath).isPlaying")
		cSyncDataManager.write("false", toKeyPath: "\(csyncPath).isActive")
        AccountDataManager.sharedInstance.deleteInvites()
	}
	
	private func setupHost() {
		// Create node so others can listen to it
		cSyncDataManager.write("", toKeyPath: csyncPath)
		// Creat heartbeat node so others can create in it
		cSyncDataManager.write("", toKeyPath: csyncPath + ".heartbeat", withACL: .PublicReadCreate)
		// Creat chat node so others can create in it
		cSyncDataManager.write("", toKeyPath: csyncPath + ".chat", withACL: .PublicReadCreate)
		// Set stream to active
		cSyncDataManager.write("true", toKeyPath: csyncPath + ".isActive")
        // Set state of inital video
        send(playState: false)
		
		NotificationCenter.default.addObserver(self, selector: #selector(receivedWillTerminateNotification), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
	}
	
	private func setupParticipant() {
		listenerKey = cSyncDataManager.createKey(atPath: csyncPath + ".*")
		listenerKey?.listen() {[weak self] value, error in
			if let value = value, let `self` = self {
				if !value.exists {
					return
				}
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
	}
	
	@objc private func receivedWillTerminateNotification(_ notification: Notification) {
		endStream()
	}
	
	// Returns position inserted in
	private func insertIntoMessages(_ message: Message) -> Int {
		if messages.isEmpty {
			messages.append(message)
			return 0
		}
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
