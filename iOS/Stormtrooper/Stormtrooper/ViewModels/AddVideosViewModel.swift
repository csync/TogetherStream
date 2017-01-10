//
//  AddVideosViewModel.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 1/10/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

class AddVideosViewModel {
	
	private let youtubeDataManager = YouTubeDataManager.sharedInstance
	
	func fetchTrendingVideos(callback: @escaping (Error?, [Video]?) -> Void) {
		youtubeDataManager.fetchTrendingVideos(callback: callback)
	}
	
	func searchForVideos(withQuery query: String, callback: @escaping (Error?, [Video]?) -> Void) {
		youtubeDataManager.searchForVideos(withQuery: query, callback: callback)
	}
}
