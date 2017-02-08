//
//  AddVideosViewModel.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 1/10/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import UIKit

class AddVideosViewModel {
    
    var videos: [Video] = []
    
    private var fastSearchSelectedVideos: Set<Video> = []
    
    private(set) var selectedVideos: [Video] = []
	
	private let youtubeDataManager = YouTubeDataManager.sharedInstance
    
    func toggleSelectionOfVideo(at indexPath: IndexPath) {
        let video = videos[indexPath.row]
        if fastSearchSelectedVideos.contains(video) {
            fastSearchSelectedVideos.remove(video)
            for (index, selectedVideo) in selectedVideos.enumerated() {
                if video == selectedVideo {
                    selectedVideos.remove(at: index)
                    break
                }
            }
        }
        else {
            fastSearchSelectedVideos.insert(video)
            selectedVideos.append(video)
        }
    }
    
    func videoIsSelected(at indexPath: IndexPath) -> Bool {
        return fastSearchSelectedVideos.contains(videos[indexPath.row])
    }
	
	func fetchTrendingVideos(callback: @escaping (Error?, [Video]?) -> Void) {
        youtubeDataManager.fetchTrendingVideos() {error, videos in
            if let videos = videos {
                self.videos = videos
            }
            callback(error, videos)
        }
	}
	
	func searchForVideos(withQuery query: String, callback: @escaping (Error?, [Video]?) -> Void) {
        youtubeDataManager.searchForVideos(withQuery: query) {error, videos in
            if let videos = videos {
                self.videos = videos
            }
            callback(error, videos)
        }
	}
}
