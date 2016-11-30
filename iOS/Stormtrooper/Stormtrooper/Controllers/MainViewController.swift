//
//  ViewController.swift
//  Stormtrooper
//
//  Created by Nathan Hekman on 11/23/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var playerView: YTPlayerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.setupPlayerView()
        
    }
    
    private func setupPlayerView() {
        self.playerView.delegate = self
        //self.playerView.loadPlaylist(byVideos: ["4NFDhxhWyIw", "RTDuUiVSCo4"], index: 0, startSeconds: 0, suggestedQuality: .auto)
        self.playerView.load(withVideoId: "4NFDhxhWyIw", playerVars: [
            "playsinline" : 1,
            "modestbranding" : 1,
            "showinfo" : 0,
            "controls" : 0,
            "playlist": "RTDuUiVSCo4"
            ])
        
    }
    
    @IBAction func playTapped(_ sender: Any) {
        self.playerView.playVideo()
    }
    
    @IBAction func pauseTapped(_ sender: Any) {
        self.playerView.pauseVideo()
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        guard let playlistCount = self.playerView.playlist()?.count else {
            return
        }
        let playlistIndex = self.playerView.playlistIndex() + 1
        if playlistIndex < Int32(playlistCount) {
            self.playerView.playVideo(at: playlistIndex)
        }
    }

    @IBAction func backTapped(_ sender: Any) {
        guard let playlistCount = self.playerView.playlist()?.count else { //doesnt work
            return
        }
        let playlistIndex = self.playerView.playlistIndex() - 1
        if playlistIndex < Int32(playlistCount) {
            self.playerView.playVideo(at: playlistIndex)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension MainViewController: YTPlayerViewDelegate {
    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {

    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        switch (state) {
        case .paused:
            //self.playerView.playVideo()
            break
        case .buffering:
            break
        case .playing:
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
