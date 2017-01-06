//
//  HomeViewModel.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 1/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import UIKit
import Foundation

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
	
	func stopStreamsListening() {
		for stream in streams {
			stream.stopListeningForCurrentVideo()
		}
	}
	
	func getThumbnailForVideo(withID id: String, callback: @escaping (Error?, UIImage?) -> Void) {
		guard let url = URL(string: "https://img.youtube.com/vi/\(id)/hqdefault.jpg") else {
			callback(ServerError.cannotFormURL, nil)
			return
		}
		let task = URLSession.shared.dataTask(with: url) {data, response, error in
			guard let data = data, let image = UIImage(data: data) else {
				callback(ServerError.unexpectedResponse, nil)
				return
			}
			callback(nil, image)
		}
		task.resume()
	}
	
}
