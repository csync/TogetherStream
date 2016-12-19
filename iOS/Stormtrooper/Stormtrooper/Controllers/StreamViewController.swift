//
//  StreamViewController.swift
//  Stormtrooper
//
//  Created by Nathan Hekman on 11/23/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit
import CSyncSDK

class StreamViewController: UIViewController {
    @IBOutlet weak var playerView: YTPlayerView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var mediaControllerView: UIView!
	@IBOutlet weak var chatTextView: UITextView!
	@IBOutlet weak var chatInputTextField: UITextField!
    
    var isPlaying = false
	
	private let maximumDesyncTime: Float = 1.0
	
	fileprivate var cSyncDataManager = CSyncDataManager.sharedInstance
	fileprivate let streamPath = "streams.10153854936447000"
	private var heartbeatDataManager: HeartbeatDataManager?
	private var chatDataManager: ChatDataManager?
	
	private var listenerKey: Key?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.setupPlayerView()
		
		// Create node so others can listen to it
		cSyncDataManager.write("", toKeyPath: streamPath)
		// Creat heartbeat node so others can create in it
		cSyncDataManager.write("", toKeyPath: streamPath + ".heartbeat", withACL: .PublicReadCreate)
		// Creat chat node so others can create in it
		cSyncDataManager.write("", toKeyPath: streamPath + ".chat", withACL: .PublicReadCreate)
		
		heartbeatDataManager = HeartbeatDataManager(streamPath: streamPath, id: FacebookDataManager.sharedInstance.profile?.userID ?? "")
		chatDataManager = ChatDataManager(streamPath: streamPath, id: FacebookDataManager.sharedInstance.profile?.userID ?? "")
		chatDataManager?.didRecieveMessage = {[unowned self] message in
			FacebookDataManager.sharedInstance.fetchInfoForUser(withID: message.id) { error, user in
				if let user = user {
					self.chatTextView.text = (self.chatTextView.text ?? "") + "\(user.name): \(message.content)\n"
				}
			}
		}
		
		if FacebookDataManager.sharedInstance.profile?.userID != "10153854936447000" {
			listenerKey = cSyncDataManager.createKey(atPath: streamPath + ".*")
			listenerKey?.listen() {value, error in
				if let value = value {
					switch value.key.components(separatedBy: ".").last ?? "" {
						case "currentURL" where value.data ?? "" != self.playerView.videoUrl()?.absoluteString:
							self.playerView.loadVideo(byURL: value.data ?? "", startSeconds: 0, suggestedQuality: .auto)
						case "isPlaying" where value.data == "true" && self.playerView.playerState() != .playing:
							self.playerView.playVideo()
						case "isPlaying" where value.data == "false" && self.playerView.playerState() != .paused:
							self.playerView.pauseVideo()
						case "playTime":
							if let time = Float(value.data ?? ""), abs(time - self.playerView.currentTime()) > self.maximumDesyncTime {
								self.playerView.seek(toSeconds: time, allowSeekAhead: true)
							}
						default:
							break
					}
				}
			}
		}
		
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
			chatDataManager?.send(message: text)
		}
		sender.resignFirstResponder()
		sender.text = nil
	}

}

extension StreamViewController: YTPlayerViewDelegate {
    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {
		cSyncDataManager.write(String(playerView.currentTime()), toKeyPath: streamPath + ".playTime")
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
		if let url = playerView.videoUrl() {
			cSyncDataManager.write(url.absoluteString, toKeyPath: streamPath + ".currentURL")
		}
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
			cSyncDataManager.write("false", toKeyPath: streamPath + ".isPlaying")
            break
        case .buffering:
            break
        case .playing:
            self.playPauseButton.setTitle("⏸", for: .normal)
            self.isPlaying = true
			cSyncDataManager.write("true", toKeyPath: streamPath + ".isPlaying")
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
