//
//  ChatDataManager.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 12/15/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation
import CSyncSDK

class ChatDataManager {
	var didRecieveMessage: ((Message) -> Void)?
	private let csyncDataManager = CSyncDataManager.sharedInstance
	private let streamPath: String
	private let id: String
	private var listenChatKey: Key
	
	init(streamPath: String, id: String) {
		self.streamPath = streamPath
		self.id = id
		listenChatKey = csyncDataManager.createKey(atPath: streamPath + ".chat.*")
		setupChatListner()
	}
	
	func send(message: String) {
		let sendKey = csyncDataManager.createKey(atPath: streamPath + ".chat." + UUID().uuidString)
		sendKey.write("{\"id\":\"\(id)\", \"content\":\"\(message)\", \"timestamp\":\"\(Date.timeIntervalSinceReferenceDate)\"}")
	}
	
	private func setupChatListner() {
		listenChatKey.listen {[weak self] value, error in
			if let error = error {
				print(error)
			}
			if let content = value?.data, let message = Message(content: content) {
				self?.didRecieveMessage?(message)
			}
		}
	}
	
	deinit {
		listenChatKey.unlisten()
	}
}
