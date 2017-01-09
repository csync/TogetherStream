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
	func recievedUpdate(forPlaytime playtime: Float) -> Void
}

class StreamViewModel {
	
	weak var delegate: StreamViewModelDelegate?
	
	var userCount: Int {
		return currentUserIDs.count
	}
	
	var messages: [Message] = []
	let maximumDesyncTime: Float = 1.0
	var isHost: Bool {
		// TODO: not hardcode
		return FacebookDataManager.sharedInstance.profile?.userID == "10153854936447000"
	}
	
	private let streamPath = "streams.10153854936447000"
	private var listenerKey: Key?
	private var cSyncDataManager = CSyncDataManager.sharedInstance
	private var heartbeatDataManager: HeartbeatDataManager?
	private var chatDataManager: ChatDataManager?
	private var participantsDataManager: ParticipantsDataManager?
	private var currentUserIDs: Set<String> = []
	
	init() {
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
			if self.isHost {
				for userID in changedUsers {
					if heartbeats.contains(userID) {
						self.send(participantID: userID, isJoining: true)
					}
					else {
						self.send(participantID: userID, isJoining: false)
					}
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
	
	func send(chatMessage: String) {
		chatDataManager?.send(message: chatMessage)
	}
	
	func send(participantID: String, isJoining: Bool) {
		participantsDataManager?.send(participantID: participantID, isJoining: isJoining)
	}
	
	func send(currentPlayTime: Float) {
		cSyncDataManager.write(String(currentPlayTime), toKeyPath: streamPath + ".playTime")
	}
	
	func send(playState: Bool) {
		let stateMessage = playState ? "true" : "false"
		cSyncDataManager.write(stateMessage, toKeyPath: streamPath + ".isPlaying")
	}
	
	func send(currentVideoID: String) {
		cSyncDataManager.write(currentVideoID, toKeyPath: streamPath + ".currentVideoID")
	}
	
	private func setupHost() {
		// Create node so others can listen to it
		cSyncDataManager.write("", toKeyPath: streamPath)
		// Creat heartbeat node so others can create in it
		cSyncDataManager.write("", toKeyPath: streamPath + ".heartbeat", withACL: .PublicReadCreate)
		// Creat chat node so others can create in it
		cSyncDataManager.write("", toKeyPath: streamPath + ".chat", withACL: .PublicReadCreate)
	}
	
	private func setupParticipant() {
		listenerKey = cSyncDataManager.createKey(atPath: streamPath + ".*")
		listenerKey?.listen() {[unowned self] value, error in
			if let value = value {
				switch value.key.components(separatedBy: ".").last ?? "" {
				case "currentVideoID":
					if let id = value.data {
						self.delegate?.recievedUpdate(forCurrentVideoID: id)
					}
				case "isPlaying" where value.data == "true":
					self.delegate?.recievedUpdate(forIsPlaying: true)
				case "isPlaying" where value.data == "false":
					self.delegate?.recievedUpdate(forIsPlaying: false)
				case "playTime":
					if let playtime = Float(value.data ?? "") {
						self.delegate?.recievedUpdate(forPlaytime: playtime)
					}
				default:
					break
				}
			}
		}
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
