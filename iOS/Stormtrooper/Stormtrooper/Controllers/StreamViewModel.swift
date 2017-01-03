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
	func joinedRoom(user: User) -> Void
	func leftRoom(user: User) -> Void
	func recieved(message: Message) -> Void
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
	private var currentUserIDs: Set<String> = []
	
	init() {
		if !isHost {
			setupParticipant()
		}
		else {
			setupHost()
		}
		
		heartbeatDataManager = HeartbeatDataManager(streamPath: streamPath, id: FacebookDataManager.sharedInstance.profile?.userID ?? "")
		heartbeatDataManager?.didRecieveHeartbeats = {[unowned self] heartbeats in
			let changedUsers = self.currentUserIDs.symmetricDifference(heartbeats)
			self.currentUserIDs = heartbeats
			for userID in changedUsers {
				FacebookDataManager.sharedInstance.fetchInfoForUser(withID: userID) {error, user in
					if let user = user {
						if heartbeats.contains(userID) {
							self.delegate?.joinedRoom(user: user)
						}
						else {
							self.delegate?.leftRoom(user: user)
						}
					}
				}
				
			}
		}
		chatDataManager = ChatDataManager(streamPath: streamPath, id: FacebookDataManager.sharedInstance.profile?.userID ?? "")
		chatDataManager?.didRecieveMessage = {[unowned self] message in
			self.insertIntoMessages(message)
			self.delegate?.recieved(message: message)
		}
	}
	
	func send(chatMessage: String) {
		chatDataManager?.send(message: chatMessage)
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
	
	private func insertIntoMessages(_ message: Message) {
		if messages.isEmpty {
			messages.append(message)
			return
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
				highIndex = midIndex - 1
			}
			else {
				// rare case where time is exactly the same
				messages.insert(message, at: midIndex + 1)
				return
			}
		}
		messages.insert(message, at: highIndex)
	}
}
