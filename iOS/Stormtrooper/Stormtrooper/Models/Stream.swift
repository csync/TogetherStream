//
//  Stream.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 1/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import CSyncSDK

struct Stream {
	let name: String
	let hostID: String
	let csyncPath: String
	
	private var key: Key
	
	init?(jsonDictionary: [String: String]) {
		guard let hostID = jsonDictionary["user_id"], let csyncPath = jsonDictionary["csync_path"], let name = jsonDictionary["stream_name"] else {
			return nil
		}
		self.name = name
		self.hostID = hostID
		self.csyncPath = csyncPath
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
