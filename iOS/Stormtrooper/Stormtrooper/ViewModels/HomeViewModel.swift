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
    
    var numberOfRows: Int {
        return streams.count + 1
    }
	
	private let accountDataManager = AccountDataManager.sharedInstance
	private let youtubeDataManager = YouTubeDataManager.sharedInstance
	
	func refreshStreams(callback: @escaping (Error?, [Stream]?) -> Void) {
        // uncomment to test invites
//        let stream = Stream(jsonDictionary: ["user_id" : "pyVUdZ9nFZ", "csync_path": "streams.10153854936447000", "stream_name": "Super Testvsfdsfdsfadsfdsaffdsafsf", "description": "Blah fdksalhfdsakl fadskjfh sdak fsdkalfh dsaklf dskjlfhsdakhfsdakl fdaskl fdaskhl fh d", "external_accounts": ["facebook-token": "10153854936447000"]])
//        let stream2 = Stream(jsonDictionary: ["user_id" : "pyVUdZ9nFZ", "csync_path": "streams.10153854936447000", "stream_name": "Test", "description": "Blub", "external_accounts": ["facebook-token": "10153854936447000"]])
//        streams = [stream!, stream2!]
//        callback(nil, streams)
//        return
		accountDataManager.retrieveInvites {[weak self] error, streams in
			if let error = error {
                print(error)
				callback(error, nil)
			}
			else {
				self?.streams = streams ?? []
				callback(nil, streams)
			}
		}
	}
    
    func shouldSelectCell(at indexPath: IndexPath) -> Bool {
        return indexPath.row < streams.count
    }
	
	func stopStreamsListening() {
		for stream in streams {
			stream.stopListeningForCurrentVideo()
		}
	}
	
	func getVideo(withID id: String, callback: @escaping (Error?, Video?) -> Void) {
		youtubeDataManager.getVideo(withID: id, callback: callback)
	}
	
	func getThumbnailForVideo(with url: URL, callback: @escaping (Error?, UIImage?) -> Void) {
        youtubeDataManager.getThumbnailForVideo(with: url, callback: callback)
	}
	
	func resetCurrentUserStream() {
		if let username = FacebookDataManager.sharedInstance.profile?.userID {
			CSyncDataManager.sharedInstance.write("false", toKeyPath: "streams.\(username).isActive")
		}
	}
}
