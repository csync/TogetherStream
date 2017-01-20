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
    let facebookID: String
	
	private var key: Key
	
	init?(jsonDictionary: [String: Any]) {
		guard let hostID = jsonDictionary["user_id"] as? String,
            let csyncPath = jsonDictionary["csync_path"] as? String,
            let name = jsonDictionary["stream_name"] as? String,
            let description = jsonDictionary["description"] as? String,
            let externalAccounts = jsonDictionary["external_accounts"] as? [String: String],
            let facebookID = externalAccounts["facebook-token"] else {
			return nil
		}
		self.name = name
		self.hostID = hostID
		self.csyncPath = csyncPath
        self.description = description
        self.facebookID = facebookID
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
	
	
}
