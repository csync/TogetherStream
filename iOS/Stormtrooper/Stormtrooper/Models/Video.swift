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
	
    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
	init?(listVideoData: [String: Any]) {
		// Check to make sure the video can be played in app
		guard isEmbeddable(listVideoData), !isBlocked(listVideoData) else {
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
        
        if let viewCountInt = Int(viewCount) {
            self.viewCount = Video.numberFormatter.string(from: NSNumber(value: viewCountInt))
        } else {
            self.viewCount = viewCount
        }
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


// Note: these functions are outside the class so they can be called
// before all stored properties are initialized
fileprivate func isEmbeddable(_ videoData: [String: Any]) -> Bool {
    return (videoData["status"] as? [String: Any])?["embeddable"] as? Bool ?? false
}

fileprivate func isBlocked(_ videoData: [String: Any]) -> Bool {
    guard let region = Locale.current.regionCode,
        let blockedRegions = ((videoData["contentDetails"] as? [String: Any])?["regionRestriction"] as? [String: [String]])?["blocked"] else {
            return false
    }
    return blockedRegions.first(where: {$0 == region}) != nil
}
