//
//  YouTubeDataManager.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 1/10/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import UIKit

class YouTubeDataManager {
	static let sharedInstance = YouTubeDataManager()
	
	private let apiKey = Utils.getStringValueWithKeyFromPlist("keys", key: "youtube_api_key")
	private let maxVideoResults = 25
	
    // TODO: Cache
	func getThumbnailForVideo(with url: URL, callback: @escaping (Error?, UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) {data, response, error in
            guard let data = data, let image = UIImage(data: data) else {
                callback(ServerError.unexpectedResponse, nil)
                return
            }
            callback(nil, image)
        }
        task.resume()
	}
	
	func getVideo(withID id: String, callback: @escaping (Error?, Video?) -> Void) {
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
        var urlString = "https://www.googleapis.com/youtube/v3/videos?chart=mostPopular&part=snippet,status,statistics,contentDetails&maxResults=\(maxVideoResults)"
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
		guard let apiKey = apiKey,
            //need to replace spaces with "+", escape special characters
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
