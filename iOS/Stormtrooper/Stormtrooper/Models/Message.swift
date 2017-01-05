//
//  Message.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 12/15/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation

struct Message {
	// Note: This is the application user ID, not FB
	let authorID: String
	let content: String
	let timestamp: TimeInterval
	
	init?(content: String) {
		guard let data = content.data(using: .utf8) else {
			return nil
		}
		do {
			guard let messageJson = try JSONSerialization.jsonObject(with: data) as? [String: String], let id = messageJson["id"], let content = messageJson["content"], let timestamp = TimeInterval(messageJson["timestamp"] ?? "") else {
				return nil
			}
			self.authorID = id
			self.content = content
			self.timestamp = timestamp
		}
		catch {
			return nil
		}
	}
}
