//
//  AddVideosViewModel.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 1/10/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

class AddVideosViewModel {
    
    var videos: [Video] = []
    
    var selectedVideos: Set<Video> = []
	
	private let youtubeDataManager = YouTubeDataManager.sharedInstance
    
    func toggleSelectionOfVideo(at indexPath: IndexPath) {
        let video = videos[indexPath.row]
        if selectedVideos.contains(video) {
            selectedVideos.remove(video)
        }
        else {
            selectedVideos.insert(video)
        }
    }
    
    func videoIsSelected(at indexPath: IndexPath) -> Bool {
        return selectedVideos.contains(videos[indexPath.row])
    }
	
	func fetchTrendingVideos(callback: @escaping (Error?, [Video]?) -> Void) {
        youtubeDataManager.fetchTrendingVideos() {error, videos in
            if let videos = videos {
                self.videos = videos
                callback(error, videos)
            }
        }
	}
	
	func searchForVideos(withQuery query: String, callback: @escaping (Error?, [Video]?) -> Void) {
        youtubeDataManager.searchForVideos(withQuery: query) {error, videos in
            if let videos = videos {
                self.videos = videos
                callback(error, videos)
            }
        }
	}
    
    func getThumbnailForVideo(with url: URL, callback: @escaping (Error?, UIImage?) -> Void) {
        youtubeDataManager.getThumbnailForVideo(with: url, callback: callback)
    }
}
