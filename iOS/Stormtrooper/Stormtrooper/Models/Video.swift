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
	let mediumThumbnailURL: URL
    let defaultThumbnailURL: URL
	let channelTitle: String
    let viewCount: String?
	
	init?(listVideoData: [String: Any]) {
		// Check to make sure the video can be played in app
		if (listVideoData["status"] as? [String: Any])?["embeddable"] as? Bool != true {
			return nil
		}
		let snippetInfo = listVideoData["snippet"] as? [String: Any]
        let thumbnailsInfo = snippetInfo?["thumbnails"] as? [String: [String : Any]]
        let statisticsInfo = listVideoData["statistics"] as? [String: String]
        guard let id = listVideoData["id"] as? String,
            let title = (snippetInfo?["localized"] as? [String: String])?["title"],
            let mediumThumbnailURLString = thumbnailsInfo?["medium"]?["url"] as? String,
            let defaultThumbnailURLString = thumbnailsInfo?["default"]?["url"] as? String,
            let channelTitle = snippetInfo?["channelTitle"] as? String,
            let mediumThumbnailURL = URL(string: mediumThumbnailURLString),
            let defaultThumbnailURL = URL(string: defaultThumbnailURLString),
            let viewCount = statisticsInfo?["viewCount"] else {
			return nil
		}
		
		self.id = id
		self.title = title
		self.mediumThumbnailURL = mediumThumbnailURL
        self.defaultThumbnailURL = defaultThumbnailURL
		self.channelTitle = channelTitle
        self.viewCount = viewCount
	}
	
	init?(searchResultData: [String: Any]) {
		let snippetInfo = searchResultData["snippet"] as? [String: Any]
        let thumbnailsInfo = snippetInfo?["thumbnails"] as? [String: [String : Any]]
		guard let id = (searchResultData["id"] as? [String: String])?["videoId"],
            let title = snippetInfo?["title"] as? String,
            let mediumThumbnailURLString = thumbnailsInfo?["medium"]?["url"] as? String,
            let defaultThumbnailURLString = thumbnailsInfo?["default"]?["url"] as? String,
            let channelTitle = snippetInfo?["channelTitle"] as? String,
            let mediumThumbnailURL = URL(string: mediumThumbnailURLString),
            let defaultThumbnailURL = URL(string: defaultThumbnailURLString) else {
			return nil
		}
		
		self.id = id
		self.title = title
		self.mediumThumbnailURL = mediumThumbnailURL
        self.defaultThumbnailURL = defaultThumbnailURL
		self.channelTitle = channelTitle
        self.viewCount = nil
	}
}

extension Video: Hashable {
    static func ==(lhs: Video, rhs: Video) -> Bool {
        return lhs.id == rhs.id
    }
    
    var hashValue: Int { return id.hashValue }
}
