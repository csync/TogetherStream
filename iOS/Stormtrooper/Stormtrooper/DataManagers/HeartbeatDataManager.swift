//
//  HeartbeatDataManager.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 12/14/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation
import CSyncSDK

/// Manages sending and receiving heartbeats of users.
/// Used to determine who is connected to a given stream.
class HeartbeatDataManager {
	/// Closure to call when heartbeats are received.
	var didReceiveHeartbeats: ((Set<String>) -> Void)?
    
    
	/// Shorthand for CSyncDataManager
	private let csyncDataManager = CSyncDataManager.sharedInstance
	/// The id of the user who is sending the heartbeat.
	private let id: String
	/// The CSync key path that the heartbeats are stored.
	private var rootHeartbeatPath: String
	/// The CSync key path of where the sending heartbeat should be stored.
	private var userHeartbeatPath: String {
		return rootHeartbeatPath + "." + id
	}
	/// Timer to send heartbeats,
	private var heartbeatTimer: Timer?
	/// Timer to send receiver the current heartbeats.
	private var pulseTimer: Timer?
	/// CSync key of the heartbeat storage
	private var pulseKey: Key
	/// Holds the beats received. Maps the user's id to the timestamp it was sent
	private var streamHeartbeats: [String: String] = [:]
	
	/// Interval to send heartbeat in seconds.
	private let beatInterval: TimeInterval = 0.5
	/// Interval to send heartbeats to receiver.
	private let checkPulseInterval: TimeInterval = 1
	/// Amount of time till a hearbeat is considered expired and invalid in seconds.
	private let heartbeatExpiredInterval: TimeInterval = 10
	
	/// Creates a new HeartbeatDataManager
	///
	/// - Parameters:
	///   - streamPath: The CSync key path of the stream.
	///   - id: The id of the user who will be sending the heartbeat.
	init(streamPath: String, id: String) {
		self.id = id
		self.rootHeartbeatPath = streamPath + ".heartbeat"
		pulseKey = csyncDataManager.createKey(atPath: rootHeartbeatPath + ".*")
		setupSendingHeartbeat()
		setupCheckingPulse()
	}
	
	/// Sets up the heartbeat sender
	private func setupSendingHeartbeat() {
		heartbeatTimer = Timer.scheduledTimer(withTimeInterval: beatInterval, repeats: true) {[weak self] _ in
			if let `self` = self {
				let currentTime = String(Date.timeIntervalSinceReferenceDate)
				self.csyncDataManager.write(currentTime, toKeyPath: self.userHeartbeatPath, withACL: .PublicReadWrite)
			}
		}
	}
	
	/// Sets up the heartbeat receiver
	private func setupCheckingPulse() {
        // Listen for changes to heartbeats on CSync
		pulseKey.listen() { [weak self] value, error in
			if let error = error {
				print(error)
			}
			if let value = value {
                // Gets ID from last component of the key
				let userID = value.key.components(separatedBy: ".").last ?? ""
                // If value doesn't exist anymore, mark the user as gone, otherwise store their timestamp.
				if value.exists == false {
					self?.streamHeartbeats[userID] = nil
				}
				else {
					self?.streamHeartbeats[userID] = value.data
				}
			}
		}
		
        // Send out current heartbeats to reiver
		pulseTimer = Timer.scheduledTimer(withTimeInterval: checkPulseInterval, repeats: true) {[weak self] _ in
			if let `self` = self {
				let currentTime = Date.timeIntervalSinceReferenceDate
                // Filters out expired heartbeats
				let currentHeartbeats = self.streamHeartbeats
					.filter{currentTime - (TimeInterval($0.1) ?? 0) < self.heartbeatExpiredInterval}
					.map {$0.0}
				self.didReceiveHeartbeats?(Set(currentHeartbeats))
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
