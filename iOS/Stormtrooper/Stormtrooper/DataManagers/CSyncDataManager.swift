//
//  CSyncDataManager.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 12/9/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation
import CSyncSDK

class CSyncDataManager {
	static let sharedInstance = CSyncDataManager()
	
	private let csyncURL = "169.46.154.75"
	private let csyncPort = 6005
	private lazy var app: App = { [unowned self] in
		return App(host: self.csyncURL, port: self.csyncPort, options: ["useSSL":"NO" as AnyObject, "dbInMemory":"YES" as AnyObject])
	}()
	
	func authenticate(withID id: String) {
		app.authenticate("demo", token: "demoToken(\(id))") {authData, error in
		}
	}
	
	func write(_ value: String, toKeyPath path: String, withACL acl: ACL = .PublicRead) {
		let key = app.key(path)
		key.write(value, with: acl) { key, error in
			if let error = error {
				print(error)
			}
		}
	}
	
	func deleteKey(atPath path: String) {
		let key = app.key(path)
        key.delete()
	}
	
	func createKey(atPath path: String) -> Key {
		return app.key(path)
	}
	
	func listenOnce(toKey key: Key, callback: @escaping (Value?, NSError?) -> ()) {
		key.listen() { value, error in
			key.unlisten()
			callback(value, error)
		}
	}
	
	private init(){}
}
