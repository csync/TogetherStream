//
//  ParticipantMessage.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 1/9/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

struct ParticipantMessage: Message {
	let subjectID: String
	let timestamp: TimeInterval
	
	let isJoining: Bool
	
	init?(content: String) {
		guard let data = content.data(using: .utf8) else {
			return nil
		}
		do {
			guard let messageJson = try JSONSerialization.jsonObject(with: data) as? [String: String], let participantID = messageJson["id"], let isJoining = messageJson["isJoining"], let timestamp = TimeInterval(messageJson["timestamp"] ?? "") else {
				return nil
			}
			self.subjectID = participantID
			self.isJoining = isJoining == "true" ? true : false
			self.timestamp = timestamp
		}
		catch {
			return nil
		}
	}
}
