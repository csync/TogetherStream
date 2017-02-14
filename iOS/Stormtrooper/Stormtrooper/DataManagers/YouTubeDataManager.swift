//
//  YouTubeDataManager.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 1/10/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import UIKit

/// Manages requests to the YouTube API
class YouTubeDataManager {
	/// Singleton object
	static let sharedInstance = YouTubeDataManager()
	
	/// Youtube API key for the project.
	private let apiKey = Utils.getStringValueWithKeyFromPlist("keys", key: "youtube_api_key")
	/// The maximum amount of videos to fetch for searches and trending videos.
	private let maxVideoResults = 25
	
	/// Fetches the video for the given id.
	///
	/// - Parameters:
	///   - id: The id of the video.
    ///   - callback: The callback called on completion. Will return an error
    /// or the video.
	func fetchVideo(withID id: String, callback: @escaping (Error?, Video?) -> Void) {
        // Configure URL
		guard let apiKey = apiKey, let url = URL(string: "https://www.googleapis.com/youtube/v3/videos?key=\(apiKey)&part=snippet,status,statistics&id=\(id)") else {
			callback(ServerError.cannotFormURL, nil)
			return
		}
		let task = URLSession.shared.dataTask(with: url) {data, response, error in
			guard let data = data, error == nil else {
				callback(error, nil)
				return
			}
			do {
                // Parses Result
				let result = try JSONSerialization.jsonObject(with: data)
				let videos = self.parseVideosResponse(result, fromSearchRequest: false)
				let video = videos.count > 0 ? videos[0] : nil
				callback(nil, video)
			}
			catch {
				callback(error, nil)
			}
		}
		
		task.resume()
	}
	
	/// Fetches the current trending videos.
	///
    /// - Parameter callback: The callback called on completion. Will return an error
    /// or the videos.
	func fetchTrendingVideos(callback: @escaping (Error?, [Video]?) -> Void) {
        // Configure URL
        var urlString = "https://www.googleapis.com/youtube/v3/videos?chart=mostPopular&part=snippet,status,statistics,contentDetails&maxResults=\(maxVideoResults)"
        // Add the current region if available
        if let regionCode = Locale.current.regionCode {
            urlString += "&regionCode=\(regionCode)"
        }
		guard let apiKey = apiKey,
            let url = URL(string: urlString + "&key=\(apiKey)") else {
			callback(ServerError.cannotFormURL, nil)
			return
		}
        
		let task = URLSession.shared.dataTask(with: url) {data, response, error in
			
			guard let data = data, error == nil else {
				callback(error, nil)
				return
			}
			
			do {
                // Parses result
				let result = try JSONSerialization.jsonObject(with: data)
				let videos = self.parseVideosResponse(result, fromSearchRequest: false)
				callback(nil, videos)
			}
			catch {
				callback(error, nil)
			}
		}
		
		task.resume()
	}
	
	/// Search for videos matching the given query.
	///
	/// - Parameters:
	///   - query: The query to match against.
    ///   - callback: The callback called on completion. Will return an error
    /// or the videos.
	func searchForVideos(withQuery query: String, callback: @escaping (Error?, [Video]?) -> Void) {
		// Configure the URL
		guard let apiKey = apiKey,
            // Need to replace spaces with "+", escape special characters
            let spaceFreeQuery = query.replacingOccurrences(of: " ", with: "+").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: "https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=\(maxVideoResults)&q=\(spaceFreeQuery)&type=video&videoEmbeddable=true&videoSyndicated=true&key=\(apiKey)") else {
			callback(ServerError.cannotFormURL, nil)
			return
		}
		let task = URLSession.shared.dataTask(with: url) {data, response, error in
			
			guard let data = data, error == nil else {
				callback(error, nil)
				return
			}
			
			do {
                // Parse results
				let result = try JSONSerialization.jsonObject(with: data)
				let videos = self.parseVideosResponse(result, fromSearchRequest: true)
				callback(nil, videos)
			}
			catch {
				callback(error, nil)
			}
		}
		
		task.resume()
	}
	
	private init() {}
	
	/// Parses the results data into videos.
	///
	/// - Parameters:
	///   - data: The data to parse.
	///   - fromSearchRequest: Whether the data is from a search request (true) or from the list API videos (false)
	/// - Returns: The data parsed into Video objects.
	private func parseVideosResponse(_ data: Any, fromSearchRequest: Bool) -> [Video] {
		let data = data as? [String: Any]
		let videosData = data?["items"] as? [[String : Any]] ?? []
		var videos: [Video] = []
		for videoData in videosData {
            // Data is in a different format depending on how it was received
			if fromSearchRequest {
				if let video = Video(searchResultData: videoData) {
					videos.append(video)
				}
			}
			else if let video = Video(listVideoData: videoData) {
				videos.append(video)
			}
		}
		return videos
	}

}
