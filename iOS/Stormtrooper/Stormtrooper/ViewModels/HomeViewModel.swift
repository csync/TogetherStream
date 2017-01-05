//
//  HomeViewModel.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 1/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

class HomeViewModel {
	var streams: [Stream] = []
	
	private let accountDataManager = AccountDataManager.sharedInstance
	
	func refreshStreams(callback: @escaping (Error?, [Stream]?) -> Void) {
		accountDataManager.retrieveInvites {[weak self] error, streams in
			if let error = error {
				callback(error, nil)
			}
			else {
				self?.streams = streams ?? []
				callback(nil, streams)
			}
		}
	}
}
