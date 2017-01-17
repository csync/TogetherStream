//
//  Stream.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 1/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import CSyncSDK

class Stream {
	let name: String
	// Note: This is the application user ID, not FB
	let hostID: String
	let csyncPath: String
    let description: String
	
	private var key: Key
	private var facebookID: String?
	
	init?(jsonDictionary: [String: String]) {
		guard let hostID = jsonDictionary["user_id"], let csyncPath = jsonDictionary["csync_path"], let name = jsonDictionary["stream_name"], let description = jsonDictionary["description"] else {
			return nil
		}
		self.name = name
		self.hostID = hostID
		self.csyncPath = csyncPath
        self.description = description
		key = CSyncDataManager.sharedInstance.createKey(atPath: csyncPath + ".currentVideoID")
	}
	
	func listenForCurrentVideo(callback: @escaping (Error?, String?) -> Void) {
		key.listen {value, error in
			if let value = value?.data {
				callback(nil, value)
			}
			else {
				callback(error, nil)
			}
		}
	}
	
	func stopListeningForCurrentVideo() {
		key.unlisten()
	}
	
	func getFacebookID(callback: @escaping (Error?, String?) -> Void) {
		if let facebookID = facebookID {
			callback(nil, facebookID)
		}
		AccountDataManager.sharedInstance.getExternalIds(forUserID: hostID) {error, ids in
			if let error = error {
				callback(error, nil)
			}
			else {
				self.facebookID = ids?["facebook-token"]
				callback(nil, self.facebookID)
			}
			
		}
	}
	
}
