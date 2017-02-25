//
//  AddVideosViewModel.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 1/10/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import UIKit

/// View model for the "Add Videos" screen.
class AddVideosViewModel {
    
    /// The videos that should be listed in the result table.
    var listedVideos: [Video] = []
    
    /// The selected videos stored in an easily searchable way.
    private var fastSearchSelectedVideos: Set<Video> = []
    
    /// The selected videos in order of time added.
    private(set) var selectedVideos: [Video] = []
	
	/// Shorthand for the YoutubeDataManager
	private let youtubeDataManager = YouTubeDataManager.sharedInstance
    
    /// Changes status of video at index path between selected
    /// and not selected.
    ///
    /// - Parameter indexPath: The path of the video.
    func toggleSelectionOfVideo(at indexPath: IndexPath) {
        let video = listedVideos[indexPath.row]
        if fastSearchSelectedVideos.contains(video) {
            // Deselect video
            fastSearchSelectedVideos.remove(video)
            // O(n) removal from ordered list
            for (index, selectedVideo) in selectedVideos.enumerated() {
                if video == selectedVideo {
                    selectedVideos.remove(at: index)
                    break
                }
            }
        }
        else {
            // Select video
            fastSearchSelectedVideos.insert(video)
            selectedVideos.append(video)
        }
    }
    
    /// Returns if the video for the given path is selected.
    ///
    /// - Parameter indexPath: The path of the video.
    /// - Returns: If the video is selected.
    func videoIsSelected(at indexPath: IndexPath) -> Bool {
        return fastSearchSelectedVideos.contains(listedVideos[indexPath.row])
    }
	
	/// Fetches the trending videos and updates model.
	///
    /// - Parameter callback: The callback called on completion. Will return an error
    /// or the videos.
	func fetchTrendingVideos(callback: @escaping (Error?, [Video]?) -> Void) {
        youtubeDataManager.fetchTrendingVideos() {error, videos in
            if let videos = videos {
                self.listedVideos = videos
            }
            callback(error, videos)
        }
	}
	
    /// Search for videos matching the given query and updates model.
    ///
    /// - Parameters:
    ///   - query: The query to match against.
    ///   - callback: The callback called on completion. Will return an error
    /// or the videos.
	func searchForVideos(withQuery query: String, callback: @escaping (Error?, [Video]?) -> Void) {
        youtubeDataManager.searchForVideos(withQuery: query) {error, videos in
            if let videos = videos {
                self.listedVideos = videos
            }
            callback(error, videos)
        }
	}
}
