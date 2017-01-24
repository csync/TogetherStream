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
	func recieved(message: Message, for position: Int) -> Void
	func recievedUpdate(forCurrentVideoID currentVideoID: String) -> Void
	func recievedUpdate(forIsPlaying isPlaying: Bool) -> Void
	func recievedUpdate(forIsBuffering isBuffering: Bool) -> Void
	func recievedUpdate(forPlaytime playtime: Float) -> Void
	func streamEnded() -> Void
}

class StreamViewModel {
	
	weak var delegate: StreamViewModelDelegate?
	
	var hostID = ""
	
	var userCount: Int {
		return currentUserIDs.count
	}
	
	fileprivate(set) var messages: [Message] = []
	fileprivate(set) var hostPlaying = false
	let maximumDesyncTime: Float = 1.0
	var isHost: Bool {
		return FacebookDataManager.sharedInstance.profile?.userID == hostID
	}
	
	private lazy var streamPath: String = {return "streams.\(self.hostID)"}()
	private var listenerKey: Key?
	private var cSyncDataManager = CSyncDataManager.sharedInstance
	private var heartbeatDataManager: HeartbeatDataManager?
	private var chatDataManager: ChatDataManager?
	private var participantsDataManager: ParticipantsDataManager?
	private var currentUserIDs: Set<String> = []
	
	init(hostID: String) {
		self.hostID = hostID
		if !isHost {
			setupParticipant()
		}
		else {
			setupHost()
		}
		
		let userID = FacebookDataManager.sharedInstance.profile?.userID ?? ""
		heartbeatDataManager = HeartbeatDataManager(streamPath: streamPath, id: userID)
		heartbeatDataManager?.didRecieveHeartbeats = {[unowned self] heartbeats in
			let changedUsers = self.currentUserIDs.symmetricDifference(heartbeats)
			self.currentUserIDs = heartbeats
			self.delegate?.userCountChanged(toCount: self.userCount)
			for userID in changedUsers {
				if self.isHost {
					if heartbeats.contains(userID) {
						self.send(participantID: userID, isJoining: true)
					}
					else {
						self.send(participantID: userID, isJoining: false)
					}
				}
				else if userID == self.hostID && !heartbeats.contains(userID) {
					//self.delegate?.streamEnded()
				}
			}
		}
		
		chatDataManager = ChatDataManager(streamPath: streamPath, id: FacebookDataManager.sharedInstance.profile?.userID ?? "")
		chatDataManager?.didRecieveMessage = {[unowned self] message in
			let position = self.insertIntoMessages(message)
			self.delegate?.recieved(message: message, for: position)
		}
		
		participantsDataManager = ParticipantsDataManager(streamPath: streamPath)
		participantsDataManager?.didRecieveMessage = {[unowned self] message in
			let position = self.insertIntoMessages(message)
			self.delegate?.recieved(message: message, for: position)
		}
	}
	
	deinit {
		listenerKey?.unlisten()
		if isHost {
			endStream()
		}
	}
    
    func getVideo(withID id: String, callback: @escaping (Error?, Video?) -> Void) {
        YouTubeDataManager.sharedInstance.getVideo(withID: id, callback: callback)
    }
	
	func send(chatMessage: String) {
		chatDataManager?.send(message: chatMessage)
	}
	
	func send(participantID: String, isJoining: Bool) {
		participantsDataManager?.send(participantID: participantID, isJoining: isJoining)
	}
	
	func send(currentPlayTime: Float) {
		cSyncDataManager.write(String(currentPlayTime), toKeyPath: "\(streamPath).playTime")
	}
	
	func send(playState: Bool) {
		let stateMessage = playState ? "true" : "false"
		cSyncDataManager.write(stateMessage, toKeyPath: "\(streamPath).isPlaying")
	}
	
	func send(isBuffering: Bool) {
		let stateMessage = isBuffering ? "true" : "false"
		cSyncDataManager.write(stateMessage, toKeyPath: "\(streamPath).isBuffering")
	}
	
	func send(currentVideoID: String) {
		cSyncDataManager.write(currentVideoID, toKeyPath: "\(streamPath).currentVideoID")
	}
	
	func endStream() {
		cSyncDataManager.write("false", toKeyPath: "\(streamPath).isActive")
	}
	
	private func setupHost() {
		// Reset stream
		cSyncDataManager.deleteKey(atPath: streamPath)
		// Create node so others can listen to it
		cSyncDataManager.write("", toKeyPath: streamPath)
		// Creat heartbeat node so others can create in it
		cSyncDataManager.write("", toKeyPath: streamPath + ".heartbeat", withACL: .PublicReadCreate)
		// Creat chat node so others can create in it
		cSyncDataManager.write("", toKeyPath: streamPath + ".chat", withACL: .PublicReadCreate)
		// Set stream to active
		cSyncDataManager.write("true", toKeyPath: streamPath + ".isActive")
		
		NotificationCenter.default.addObserver(self, selector: #selector(recievedWillTerminateNotification), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
	}
	
	private func setupParticipant() {
		listenerKey = cSyncDataManager.createKey(atPath: streamPath + ".*")
		listenerKey?.listen() {[weak self] value, error in
			if let value = value, let `self` = self {
				if !value.exists {
					return
				}
				switch value.key.components(separatedBy: ".").last ?? "" {
				case "currentVideoID":
					if let id = value.data {
						self.delegate?.recievedUpdate(forCurrentVideoID: id)
					}
				case "isPlaying" where value.data == "true":
					self.hostPlaying = true
					self.delegate?.recievedUpdate(forIsPlaying: true)
				case "isPlaying" where value.data == "false":
					self.hostPlaying = false
					self.delegate?.recievedUpdate(forIsPlaying: false)
				case "isBuffering" where value.data == "true":
					self.delegate?.recievedUpdate(forIsBuffering: true)
				case "isBuffering" where value.data == "false":
					self.delegate?.recievedUpdate(forIsBuffering: false)
				case "playTime":
					if let playtime = Float(value.data ?? "") {
						self.delegate?.recievedUpdate(forPlaytime: playtime)
					}
				case "isActive" where value.data == "false":
					self.delegate?.streamEnded()
				default:
					break
				}
			}
		}
	}
	
	@objc private func recievedWillTerminateNotification(_ notification: Notification) {
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
