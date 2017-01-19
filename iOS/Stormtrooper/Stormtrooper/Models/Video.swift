//
//  Video.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 1/10/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

struct Video {
	let id: String
	let title: String
	let thumbnailURL: URL
	let channelTitle: String
	
	init?(listVideoData: [String: Any]) {
		// Check to make sure the video can be played in app
		if (listVideoData["status"] as? [String: Any])?["embeddable"] as? Bool != true {
			return nil
		}
		let snippetInfo = listVideoData["snippet"] as? [String: Any]
        guard let id = listVideoData["id"] as? String, let title = (snippetInfo?["localized"] as? [String: String])?["title"], let thumbnailURLString = (snippetInfo?["thumbnails"] as? [String: [String : Any]])?["medium"]?["url"] as? String, let channelTitle = snippetInfo?["channelTitle"] as? String, let thumbnailURL = URL(string: thumbnailURLString) else {
			return nil
		}
		
		self.id = id
		self.title = title
		self.thumbnailURL = thumbnailURL
		self.channelTitle = channelTitle
	}
	
	init?(searchResultData: [String: Any]) {
		let snippetInfo = searchResultData["snippet"] as? [String: Any]
		guard let id = (searchResultData["id"] as? [String: String])?["videoId"], let title = snippetInfo?["title"] as? String, let thumbnailURLString = (snippetInfo?["thumbnails"] as? [String: [String : Any]])?["medium"]?["url"] as? String, let channelTitle = snippetInfo?["channelTitle"] as? String, let thumbnailURL = URL(string: thumbnailURLString) else {
			return nil
		}
		
		self.id = id
		self.title = title
		self.thumbnailURL = thumbnailURL
		self.channelTitle = channelTitle
	}
}
