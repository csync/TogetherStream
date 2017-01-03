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
	@IBOutlet weak var chatTextView: UITextView!
	@IBOutlet weak var chatInputTextField: UITextField!
	@IBOutlet weak var userCountLabel: UILabel!
	
    var isPlaying = false
	
	fileprivate let viewModel = StreamViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        viewModel.delegate = self
		
        self.setupPlayerView()
		
        NotificationCenter.default.addObserver(self, selector: #selector(StreamViewController.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
		
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		if self.isBeingDismissed {
			NotificationCenter.default.removeObserver(self)
		}
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupPlayerView() {
        self.playerView.delegate = self
        //self.playerView.loadPlaylist(byVideos: ["4NFDhxhWyIw", "RTDuUiVSCo4"], index: 0, startSeconds: 0, suggestedQuality: .auto)
        self.playerView.load(withVideoId: "VGfn-NFMrXg", playerVars: [
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

    @IBAction func closeTapped(_ sender: Any) {
        let _ = self.navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func addToStreamTapped(_ sender: Any) {
        guard let addVideosVC = Utils.vcWithNameFromStoryboardWithName("addVideos", storyboardName: "Main") as? AddVideosViewController else {
            return
        }
        self.present(addVideosVC, animated: true, completion: nil)
    }
	@IBAction func chatInputActionTriggered(_ sender: UITextField) {
		if let text = sender.text {
			viewModel.send(chatMessage: text)
		}
		sender.resignFirstResponder()
		sender.text = nil
	}

}

extension StreamViewController: StreamViewModelDelegate {
	func joinedRoom(user: User) {
		chatTextView.text = (self.chatTextView.text ?? "") + "\(user.name) has joined\n"
		userCountLabel.text = "\(self.viewModel.userCount) Users"
	}
	
	func leftRoom(user: User) {
		chatTextView.text = (self.chatTextView.text ?? "") + "\(user.name) has left\n"
		userCountLabel.text = "\(self.viewModel.userCount) Users"
	}
	func recieved(message: Message) {
		chatTextView.text = ""
		for message in viewModel.messages {
			chatTextView.text = (self.chatTextView.text ?? "") + "\(message.id): \(message.content)\n"
		}
		//			FacebookDataManager.sharedInstance.fetchInfoForUser(withID: message.id) { error, user in
		//				if let user = user {
		//					self.chatTextView.text = (self.chatTextView.text ?? "") + "\(user.name): \(message.content)\n"
		//				}
		//			}
	}
	func recievedUpdate(forCurrentURL currentURL: String) {
		if currentURL != playerView.videoUrl()?.absoluteString {
			playerView.loadVideo(byURL: currentURL, startSeconds: 0, suggestedQuality: .auto)
		}
	}
	func recievedUpdate(forIsPlaying isPlaying: Bool) {
		if isPlaying && playerView.playerState() != .playing {
			playerView.playVideo()
		}
		else if !isPlaying && playerView.playerState() != .paused {
			playerView.pauseVideo()
		}
	}
	func recievedUpdate(forPlaytime playtime: Float) {
		if abs(playtime - playerView.currentTime()) > viewModel.maximumDesyncTime {
			playerView.seek(toSeconds: playtime, allowSeekAhead: true)
		}
	}
}

extension StreamViewController: YTPlayerViewDelegate {
    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {
		viewModel.send(currentPlayTime: playerView.currentTime())
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
            self.playPauseButton.setTitle("▶️", for: .normal)
            self.isPlaying = false
			viewModel.send(playState: false)
            break
        case .buffering:
			if let url = playerView.videoUrl() {
				viewModel.send(currentURL: url)
			}
        case .playing:
            self.playPauseButton.setTitle("⏸", for: .normal)
            self.isPlaying = true
			viewModel.send(playState: true)
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
