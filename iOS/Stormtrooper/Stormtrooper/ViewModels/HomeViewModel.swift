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
	private let youtubeDataManager = YouTubeDataManager.sharedInstance
	
	func refreshStreams(callback: @escaping (Error?, [Stream]?) -> Void) {
		let stream = Stream(jsonDictionary: ["user_id" : "123", "csync_path": "streams.10153854936447000", "stream_name": "Test"])
		streams = [stream!]
		callback(nil, streams)
		return
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
	
	func getVideo(withID id: String, callback: @escaping (Error?, Video?) -> Void) {
		youtubeDataManager.getVideo(withID: id, callback: callback)
	}
	
	func getThumbnailForVideo(withID id: String, callback: @escaping (Error?, UIImage?) -> Void) {
		youtubeDataManager.getThumbnailForVideo(withID: id, callback: callback)
	}
	
}
