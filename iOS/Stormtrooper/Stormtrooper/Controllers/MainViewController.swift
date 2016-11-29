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
        self.playerView.load(withVideoId: "4NFDhxhWyIw", playerVars: [
            "playsinline" : 1,
            "modestbranding" : 0,
            "playlist": "RTDuUiVSCo4"
            ])
        
    }
    
    @IBAction func playTapped(_ sender: Any) {
        self.playerView.playVideo()
    }
    
    @IBAction func pauseTapped(_ sender: Any) {
        self.playerView.pauseVideo()
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

    }
    
}
