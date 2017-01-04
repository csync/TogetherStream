//
//  Stream.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 1/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

struct Stream {
	let name: String
	let csyncPath: String
	
	init?(jsonDictionary: [String: Any]) {
		guard let name = jsonDictionary["name"] as? String, let csyncPath = jsonDictionary["csyncPath"] as? String else {
			return nil
		}
		self.name = name
		self.csyncPath = csyncPath
	}
}
