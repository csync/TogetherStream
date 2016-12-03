//
//  StreamViewController.swift
//  Stormtrooper
//
//  Created by Nathan Hekman on 11/23/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit

class StreamViewController: UIViewController {
    @IBOutlet weak var playerView: YTPlayerView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var mediaControllerView: UIView!
    
    var isPlaying = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.setupPlayerView()
        //self.requestTrendingVideos()
        self.searchForVideosWithString(videoString: "The Strokes")
        
        NotificationCenter.default.addObserver(self, selector: #selector(StreamViewController.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
		
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupPlayerView() {
        self.playerView.delegate = self
        //self.playerView.loadPlaylist(byVideos: ["4NFDhxhWyIw", "RTDuUiVSCo4"], index: 0, startSeconds: 0, suggestedQuality: .auto)
        self.playerView.load(withVideoId: "4NFDhxhWyIw", playerVars: [
            "playsinline" : 1,
            "modestbranding" : 1,
            "showinfo" : 0,
            "controls" : 0,
            "playlist": "7D3Ud2JIFhA, 2VuFqm8re5c"
            ])
        
    }
    
    func rotated() {
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
            self.playerView.frame = self.view.frame //make fullscreen if landscape
            self.mediaControllerView.isHidden = true
            print("Landscape")
        }
        
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
            self.playerView.updateConstraintsIfNeeded()
            self.mediaControllerView.isHidden = false
            print("Portrait")
        }
        
    }
    
    @IBAction func playTapped(_ sender: Any) {
        if !self.isPlaying {
           self.playerView.playVideo()
        }
        else {
            self.playerView.pauseVideo()
        }
        
    }
    
    
    @IBAction func nextTapped(_ sender: Any) {
        self.playerView.nextVideo()
    }

    @IBAction func backTapped(_ sender: Any) {
        self.playerView.previousVideo()
    }

    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func requestTrendingVideos() {
        guard let key = Utils.getStringValueWithKeyFromPlist("keys", key: "youtube_api_key") else {
            return
        }
        let urlString = "https://www.googleapis.com/youtube/v3/videos?chart=mostPopular&part=snippet&maxResults=5&videoEmbeddable=true&videoSyndicated=true&key=" + key
        Utils.performGetRequest(targetURLString: urlString, completion: { data, responseCode, error in
            
            guard error == nil else {
                print("Error receiving videos: \(error!.localizedDescription)")
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            //TODO: replace with model object creation
            //TODO: filter out restricted/premium videos from the popular video list
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            print(json)
        })
    }
    
    
    func searchForVideosWithString(videoString: String) {
        guard let key = Utils.getStringValueWithKeyFromPlist("keys", key: "youtube_api_key") else {
            return
        }
        
        //need to replace spaces with "+"
        let spaceFreeString = videoString.replacingOccurrences(of: " ", with: "+")
        
        let urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=5&q=" + spaceFreeString + "&type=video&videoEmbeddable=true&videoSyndicated=true&key=" + key
        Utils.performGetRequest(targetURLString: urlString, completion: { data, responseCode, error in
            
            guard error == nil else {
                print("Error receiving videos: \(error!.localizedDescription)")
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            //TODO: replace with model object creation
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            print(json)
        })
    }


}

extension StreamViewController: YTPlayerViewDelegate {
    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {
        print("Current Time: \(playerView.currentTime()) out of \(playerView.duration()) - Video Loaded \(playerView.videoLoadedFraction() * 100)%")
    }
    
    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
        //error received
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo quality: YTPlaybackQuality) {
        //quality changed
    }
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        // player ready --
        // could show loading before this is called, and hide loading when this is called
        print("player ready!")
    }
    
//    func playerViewPreferredInitialLoading(_ playerView: YTPlayerView) -> UIView? {
//        //return loading view to be shown before player becomes ready
//        let loadingView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
//        loadingView.backgroundColor = UIColor.red
//        return loadingView
//    }
    
//    func playerViewPreferredWebViewBackgroundColor(_ playerView: YTPlayerView) -> UIColor {
//        return UIColor.clear
//    }
    
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        switch (state) {
        case .paused:
            self.playPauseButton.setTitle("▶", for: .normal)
            self.isPlaying = false
            break
        case .buffering:
            break
        case .playing:
            self.playPauseButton.setTitle("❘ ❘", for: .normal)
            self.isPlaying = true
            break
        case .ended:
            break
        case .queued:
            break
        case .unknown:
            break
        case .unstarted:
            break
        }
    }
    
}
