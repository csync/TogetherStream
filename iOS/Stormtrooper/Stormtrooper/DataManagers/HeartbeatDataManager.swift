//
//  HeartbeatDataManager.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 12/14/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation
import CSyncSDK

class HeartbeatDataManager {
	var didRecieveHeartbeats: ((Set<String>) -> Void)?
	private let csyncDataManager = CSyncDataManager.sharedInstance
	private let id: String
	private var rootHeartbeatPath: String
	private var userHeartbeatPath: String {
		return rootHeartbeatPath + "." + id
	}
	private var heartbeatTimer: Timer?
	private var pulseTimer: Timer?
	private var pulseKey: Key
	private var streamHeartbeats: [String: String] = [:]
	
	private let beatInterval: TimeInterval = 0.5
	private let checkPulseInterval: TimeInterval = 1
	private let heartbeatExpiredInterval: TimeInterval = 10
	
	init(streamPath: String, id: String) {
		self.id = id
		self.rootHeartbeatPath = streamPath + ".heartbeat"
		pulseKey = csyncDataManager.createKey(atPath: rootHeartbeatPath + ".*")
		setupSendingHeartbeat()
		setupCheckingPulse()
		csyncDataManager.write("blah", toKeyPath: "x.y.c")
	}
	
	private func setupSendingHeartbeat() {
		heartbeatTimer = Timer.scheduledTimer(withTimeInterval: beatInterval, repeats: true) {[weak self] _ in
			if let `self` = self {
				let currentTime = String(Date.timeIntervalSinceReferenceDate)
				self.csyncDataManager.write(currentTime, toKeyPath: self.userHeartbeatPath, withACL: .PublicReadWrite)
			}
		}
	}
	
	private func setupCheckingPulse() {
		pulseKey.listen() { [weak self] value, error in
			if let error = error {
				//  handle error
				print(error)
			}
			if let value = value {
				let userID = value.key.components(separatedBy: ".").last ?? ""
				if value.exists == false {
					self?.streamHeartbeats[userID] = nil
				}
				else {
					self?.streamHeartbeats[userID] = value.data
				}
			}
		}
		
		pulseTimer = Timer.scheduledTimer(withTimeInterval: checkPulseInterval, repeats: true) {[weak self] _ in
			if let `self` = self {
				let currentTime = Date.timeIntervalSinceReferenceDate
				let currentHeartbeats = self.streamHeartbeats
					.filter{currentTime - (TimeInterval($0.1) ?? 0) < self.heartbeatExpiredInterval}
					.map {$0.0}
				self.didRecieveHeartbeats?(Set(currentHeartbeats))
			}
		}
	}
	
	deinit {
		pulseKey.unlisten()
		heartbeatTimer?.invalidate()
		pulseTimer?.invalidate()
		csyncDataManager.deleteKey(atPath: userHeartbeatPath)
	}
}
