//
//  ParticipantJoinOrLeftDataManager.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 1/9/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import CSyncSDK

class ParticipantsDataManager {
	var didRecieveMessage: ((ParticipantMessage) -> Void)?
	private let csyncDataManager = CSyncDataManager.sharedInstance
	private let streamPath: String
	private var listenParticipantsKey: Key
	
	init(streamPath: String) {
		self.streamPath = streamPath
		listenParticipantsKey = csyncDataManager.createKey(atPath: streamPath + ".participants.*")
		setupParticipantsListner()
	}
	
	func send(participantID: String, isJoining: Bool) {
		let sendKey = csyncDataManager.createKey(atPath: streamPath + ".participants." + UUID().uuidString)
		sendKey.write("{\"id\":\"\(participantID)\", \"isJoining\":\"\(isJoining)\", \"timestamp\":\"\(Date.timeIntervalSinceReferenceDate)\"}")
	}
	
	private func setupParticipantsListner() {
		listenParticipantsKey.listen {[weak self] value, error in
			if let error = error {
				print(error)
			}
			if let content = value?.data, let message = ParticipantMessage(content: content) {
				self?.didRecieveMessage?(message)
			}
		}
	}
	
	deinit {
		listenParticipantsKey.unlisten()
	}
}
