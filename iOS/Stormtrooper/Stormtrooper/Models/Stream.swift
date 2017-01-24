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
	let csyncPath: String
    let description: String
    let hostFacebookID: String
	
	private var key: Key
	
	init?(jsonDictionary: [String: Any]) {
		guard let csyncPath = jsonDictionary["csync_path"] as? String,
            let name = jsonDictionary["stream_name"] as? String,
            let description = jsonDictionary["description"] as? String,
            let externalAccounts = jsonDictionary["external_accounts"] as? [String: String],
            let hostFacebookID = externalAccounts["facebook-token"] else {
			return nil
		}
		self.name = name
		self.csyncPath = csyncPath
        self.description = description
        self.hostFacebookID = hostFacebookID
        
		key = CSyncDataManager.sharedInstance.createKey(atPath: csyncPath + ".currentVideoID")
	}
    
    init(name: String, csyncPath: String, description: String, hostFacebookID: String) {
        self.name = name
        self.csyncPath = csyncPath
        self.description = description
        self.hostFacebookID = hostFacebookID
        
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
