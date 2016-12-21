//
//  StreamViewModel.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 12/21/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation
import CSyncSDK

class StreamViewModel {
	var userJoinedRoom: ((User) -> Void)?
	var userLeftRoom: ((User) -> Void)?
	var didRecieveMessage: ((Message) -> Void)?
	var recievedCurrentURLUpdate: ((String) -> Void)?
	var recievedIsPlayingUpdate: ((Bool) -> Void)?
	var recievedPlaytimeUpdate: ((Float) -> Void)?
	
	var userCount: Int {
		return currentUserIDs.count
	}
	
	var messages: [Message] = []
	let streamPath = "streams.10153854936447000"
	let maximumDesyncTime: Float = 1.0
	
	private var listenerKey: Key?
	private var cSyncDataManager = CSyncDataManager.sharedInstance
	private var heartbeatDataManager: HeartbeatDataManager?
	private var chatDataManager: ChatDataManager?
	private var currentUserIDs: Set<String> = []
	
	init() {
		// TODO: Add real host distinction
		if FacebookDataManager.sharedInstance.profile?.userID != "10153854936447000" {
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
							self.userJoinedRoom?(user)
						}
						else {
							self.userLeftRoom?(user)
						}
					}
				}
				
			}
		}
		chatDataManager = ChatDataManager(streamPath: streamPath, id: FacebookDataManager.sharedInstance.profile?.userID ?? "")
		chatDataManager?.didRecieveMessage = {[unowned self] message in
			self.insertIntoMessages(message)
			self.didRecieveMessage?(message)
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
	
	func send(currentURL: URL) {
		cSyncDataManager.write(currentURL.absoluteString, toKeyPath: streamPath + ".currentURL")
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
				case "currentURL":
					if let url = value.data {
						self.recievedCurrentURLUpdate?(url)
					}
				case "isPlaying" where value.data == "true":
					self.recievedIsPlayingUpdate?(true)
				case "isPlaying" where value.data == "false":
					self.recievedIsPlayingUpdate?(false)
				case "playTime":
					if let playTime = Float(value.data ?? "") {
						self.recievedPlaytimeUpdate?(playTime)
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
