//
//  Stream.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 1/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

struct Stream {
	let name: String
	let hostID: String
	let csyncPath: String
	
	init?(jsonDictionary: [String: String]) {
		guard let hostID = jsonDictionary["user_id"], let csyncPath = jsonDictionary["csync_path"], let name = jsonDictionary["stream_name"] else {
			return nil
		}
		self.name = name
		self.hostID = hostID
		self.csyncPath = csyncPath
	}
}
