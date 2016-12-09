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
	
	private let csyncURL = "http://localhost"
	private let csyncPort = 6005
	private lazy var app: App = { [unowned self] in
		return App(host: self.csyncURL, port: self.csyncPort)
	}()
	
	private init(){}
}
