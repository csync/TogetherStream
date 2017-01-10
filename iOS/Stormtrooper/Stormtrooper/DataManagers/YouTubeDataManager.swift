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
	
	func getTitleForVideo(withID id: String, callback: @escaping (Error?, String?) -> Void) {
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
				let videoInfo = try JSONSerialization.jsonObject(with: data) as? [String: Any]
				let snippetInfo = ((videoInfo?["items"] as? [Any])?[0] as? [String: Any])?["snippet"] as? [String: Any]
				let title = (snippetInfo?["localized"] as? [String: String])?["title"]
				if title == nil {
					callback(ServerError.unexpectedResponse, nil)
					return
				}
				callback(nil, title)
			}
			catch {
				callback(error, nil)
			}
		}
		
		task.resume()
	}
	
	func fetchTrendingVideos(callback: @escaping (Error?, String?) -> Void) {
		guard let apiKey = apiKey, let url = URL(string: "https://www.googleapis.com/youtube/v3/videos?chart=mostPopular&part=snippet&maxResults=5&videoEmbeddable=true&videoSyndicated=true&key=\(apiKey)") else {
			callback(ServerError.cannotFormURL, nil)
			return
		}
		let task = URLSession.shared.dataTask(with: url) {data, response, error in
			
			guard let data = data, error == nil else {
				callback(error, nil)
				return
			}
			
			//TODO: replace with model object creation
			//TODO: filter out restricted/premium videos from the popular video list
			let json = try! JSONSerialization.jsonObject(with: data, options: [])
			print(json)
		}
		
		task.resume()
	}
	
	func searchForVideos(withQuery query: String, callback: @escaping (Error?, String?) -> Void) {
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
			
			//TODO: replace with model object creation
			let json = try! JSONSerialization.jsonObject(with: data, options: [])
			print(json)
		}
		
		task.resume()
	}
	
	private init() {}

}
