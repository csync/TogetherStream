//
//  ChatDataManager.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 12/15/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation
import CSyncSDK

/// Manages sending and receiving chat messages.
class ChatDataManager {
	/// Closure called when a message is received.
	var didReceiveMessage: ((ChatMessage) -> Void)?
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
		let keyPath = streamPath + ".chat." + UUID().uuidString
        let message = "{\"id\":\"\(id)\", \"content\":\"\(message)\", \"timestamp\":\"\(Date.timeIntervalSinceReferenceDate)\"}"
		csyncDataManager.write(message, toKeyPath: keyPath, withACL: .PublicReadWrite)
	}
	
	private func setupChatListner() {
		listenChatKey.listen {[weak self] value, error in
			if let error = error {
				print(error)
			}
            if value?.exists == false {
                return
            }
			if let content = value?.data, let message = ChatMessage(content: content) {
				self?.didReceiveMessage?(message)
			}
		}
	}
	
	deinit {
		listenChatKey.unlisten()
	}
}
