//
//  YouTubeDataManager.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 1/10/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

class YouTubeDataManager {
	static let sharedInstance = YouTubeDataManager()
	
	private let apiKey = Utils.getStringValueWithKeyFromPlist("keys", key: "youtube_api_key")
	private let maxSearchResults = 10
	
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
	
	func getVideo(withID id: String, callback: @escaping (Error?, Video?) -> Void) {
		guard let apiKey = apiKey, let url = URL(string: "https://www.googleapis.com/youtube/v3/videos?key=\(apiKey)&part=snippet&id=\(id)") else {
			callback(ServerError.cannotFormURL, nil)
			return
		}
		let task = URLSession.shared.dataTask(with: url) {data, response, error in
			guard let data = data, error == nil else {
				callback(error, nil)
				return
			}
			do {
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
	
	func fetchTrendingVideos(callback: @escaping (Error?, [Video]?) -> Void) {
		guard let apiKey = apiKey, let url = URL(string: "https://www.googleapis.com/youtube/v3/videos?chart=mostPopular&part=snippet&maxResults=\(maxSearchResults)&videoEmbeddable=true&videoSyndicated=true&key=\(apiKey)") else {
			callback(ServerError.cannotFormURL, nil)
			return
		}
		let task = URLSession.shared.dataTask(with: url) {data, response, error in
			
			guard let data = data, error == nil else {
				callback(error, nil)
				return
			}
			
			//TODO: filter out restricted/premium videos from the popular video list
			do {
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
	
	func searchForVideos(withQuery query: String, callback: @escaping (Error?, [Video]?) -> Void) {
		//need to replace spaces with "+"
		let spaceFreeQuery = query.replacingOccurrences(of: " ", with: "+")
		
		guard let apiKey = apiKey, let url = URL(string: "https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=5&q=\(spaceFreeQuery)&type=video&videoEmbeddable=true&videoSyndicated=true&key=\(apiKey)") else {
			callback(ServerError.cannotFormURL, nil)
			return
		}
		let task = URLSession.shared.dataTask(with: url) {data, response, error in
			
			guard let data = data, error == nil else {
				callback(error, nil)
				return
			}
			
			//TODO: filter out restricted/premium videos from the popular video list
			do {
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
	
	private func parseVideosResponse(_ data: Any, fromSearchRequest: Bool) -> [Video] {
		let data = data as? [String: Any]
		let videosData = data?["items"] as? [[String : Any]] ?? []
		var videos: [Video] = []
		for videoData in videosData {
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
