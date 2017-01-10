//
//  Video.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 1/10/17.
//  Copyright © 2017 IBM. All rights reserved.
//

struct Video {
	let id: String
	let title: String
	let thumbnailURL: String
	let channelTitle: String
	
	init?(listVideoData: [String: Any]) {
		// Check to make sure the video can be played in app
		if (listVideoData["status"] as? [String: Any])?["embeddable"] as? Bool != true {
			return nil
		}
		let snippetInfo = listVideoData["snippet"] as? [String: Any]
		guard let id = listVideoData["id"] as? String, let title = (snippetInfo?["localized"] as? [String: String])?["title"], let thumbnailURL = (snippetInfo?["thumbnails"] as? [String: [String : Any]])?["high"]?["url"] as? String, let channelTitle = snippetInfo?["channelTitle"] as? String else {
			return nil
		}
		
		self.id = id
		self.title = title
		self.thumbnailURL = thumbnailURL
		self.channelTitle = channelTitle
	}
	
	init?(searchResultData: [String: Any]) {
		let snippetInfo = searchResultData["snippet"] as? [String: Any]
		guard let id = (searchResultData["id"] as? [String: String])?["videoId"], let title = snippetInfo?["title"] as? String, let thumbnailURL = (snippetInfo?["thumbnails"] as? [String: [String : Any]])?["high"]?["url"] as? String, let channelTitle = snippetInfo?["channelTitle"] as? String else {
			return nil
		}
		
		self.id = id
		self.title = title
		self.thumbnailURL = thumbnailURL
		self.channelTitle = channelTitle
	}
}
