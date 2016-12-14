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
	
	private let csyncURL = "csync-staging.mybluemix.net"
	private let csyncPort = 80
	private lazy var app: App = { [unowned self] in
		return App(host: self.csyncURL, port: self.csyncPort, options: ["useSSL":"NO" as AnyObject, "dbInMemory":"YES" as AnyObject])
	}()
	
	func authenticate(withID id: String) {
		app.authenticate("pickles", token: "pickles_demo_token_bihsdbhiladfgbiewrpifwifabeuioaergnv(\(id))") {authData, error in
		}
	}
	
	func write(_ value: String, toKey key: String) {
		let key = app.key(key)
		key.write(value, with: .PublicRead) { value, error in
			
		}
	}
	
	private init(){}
}
