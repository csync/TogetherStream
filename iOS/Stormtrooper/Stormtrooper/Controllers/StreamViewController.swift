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
	@IBOutlet weak var chatInputTextField: UITextField!
	@IBOutlet weak var chatTableView: UITableView!
	@IBOutlet weak var userCountLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var queueView: UIView!
    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerArrowImageView: UIImageView!
    @IBOutlet weak var headerViewButton: UIButton!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    //constraints
    var originalHeaderViewHeightConstraint: CGFloat = 0
    
    //constants
    let closeButtonFrame = CGRect(x: 0, y: 0, width: 17, height: 17)
    let profileButtonFrame = CGRect(x: 0, y: 0, width: 17, height: 19)
    let headerViewAnimationDuration: TimeInterval = 0.3
	
	var hostID: String?
	
	// TODO: Remove or move to viewModel
    fileprivate var isPlaying = false
	
	fileprivate var viewModel: StreamViewModel!
    
    //accessory view shown above keyboard while chatting
    fileprivate var accessoryView: ChatTextFieldAccessoryView!

    override func viewDidLoad() {
        super.viewDidLoad()
		viewModel = StreamViewModel(hostID: hostID ?? "")
        viewModel.delegate = self
		
        
        setupPlayerView()
        setupChatTextFieldView()
        setupViewForHostOrParticipant()
        setupConstraints()
		
        NotificationCenter.default.addObserver(self, selector: #selector(StreamViewController.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
		
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.setAnimationsEnabled(true)
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

    private func setupViewForHostOrParticipant() { //TODO: add actual icons, add player setup (don't allow participant to pause, etc)
        if viewModel.isHost { //host-- can view queue, can end stream, can invite people
            headerArrowImageView.isHidden = false
            headerViewButton.isHidden = false
            
            //Set bar button items and their actions programmatically
            let closeButton = UIButton(type: .custom)
            //closeButton.setImage(UIImage(named: "stormtrooper_helmet"), for: .normal)
            closeButton.setTitle("X", for: .normal)
            closeButton.frame = closeButtonFrame
            closeButton.addTarget(self, action: #selector(StreamViewController.closeTapped), for: .touchUpInside)
            let item1 = UIBarButtonItem(customView: closeButton)
            
            let profileButton = UIButton(type: .custom)
            //profileButton.setImage(UIImage(named: "stormtrooper_helmet"), for: .normal)
            profileButton.setTitle("+", for: .normal)
            profileButton.frame = profileButtonFrame
            profileButton.addTarget(self, action: #selector(StreamViewController.profileTapped), for: .touchUpInside)
            let item2 = UIBarButtonItem(customView: profileButton)
            
            self.navigationItem.setLeftBarButtonItems([item1], animated: false)
            self.navigationItem.setRightBarButtonItems([item2], animated: false)
        }
        else { //participant-- cannot view queue, can't end stream, can't invite people
            headerArrowImageView.isHidden = true
            headerViewButton.isHidden = true
            
            //Set bar button items and their actions programmatically
            let closeButton = UIButton(type: .custom)
            //closeButton.setImage(UIImage(named: "stormtrooper_helmet"), for: .normal)
            closeButton.setTitle("<", for: .normal)
            closeButton.frame = closeButtonFrame
            closeButton.addTarget(self, action: #selector(StreamViewController.closeTapped), for: .touchUpInside) //TODO: Change this to not end stream
            let item1 = UIBarButtonItem(customView: closeButton)
            
            self.navigationItem.setLeftBarButtonItems([item1], animated: false)
        }
    }
    
    /// Adds a textfield view above keyboard when user starts typing in chat
    private func setupChatTextFieldView() {
        //new instance of accessory view
        accessoryView = ChatTextFieldAccessoryView.instanceFromNib()
        
        //set delegates of text fields
        accessoryView.textField.delegate = self
        chatInputTextField.delegate = self
        
        //add selector to dismiss and when editing to sync up both textfields
        accessoryView.cancelButton.addTarget(self, action: #selector(StreamViewController.cancelChatTapped), for: .touchUpInside)
        chatInputTextField.addTarget(self, action: #selector(StreamViewController.chatEditingChanged), for: .editingChanged)
        
        //actually set accessory view
        chatInputTextField.inputAccessoryView = accessoryView
        
        
    }
    
    private func setupConstraints() {
        originalHeaderViewHeightConstraint = headerViewHeightConstraint.constant
        
    }
    
    private func setupPlayerView() {
        self.playerView.delegate = self
        //self.playerView.loadPlaylist(byVideos: ["4NFDhxhWyIw", "RTDuUiVSCo4"], index: 0, startSeconds: 0, suggestedQuality: .auto)
		if viewModel.isHost {
			self.playerView.load(withVideoId: "VGfn-NFMrXg", playerVars: [ //TODO: hide controls if participant
				"playsinline" : 1,
				"modestbranding" : 1,
				"showinfo" : 0,
				"controls" : 1,
				"playlist": "7D3Ud2JIFhA, 2VuFqm8re5c"
				])
		}
		
    }
    
    
    func chatEditingChanged(textField: UITextField) {
        accessoryView.textField.text = chatInputTextField.text
        
    }
    
    
    
    func cancelChatTapped() {
        accessoryView.textField.resignFirstResponder()
        chatInputTextField.resignFirstResponder()
        
    }
    
    @IBAction func visualEffectViewTapped(_ sender: Any) {
        //visual effect view tapped, so dismiss keyboard if shown
        cancelChatTapped()
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
    
    //header tapped, so show or hide queue if host
    @IBAction func headerTapped(_ sender: Any) {
        if queueView.isHidden {
            
            headerViewHeightConstraint.constant = originalHeaderViewHeightConstraint + queueView.frame.height
            UIView.animate(withDuration: headerViewAnimationDuration, delay: 0, options: .curveEaseOut, animations: { _ in
                self.view.layoutIfNeeded()
            }, completion: { complete in
                self.queueView.isHidden = false
            })
        }
        else {
            self.queueView.isHidden = true
            headerViewHeightConstraint.constant = originalHeaderViewHeightConstraint
            UIView.animate(withDuration: headerViewAnimationDuration, delay: 0, options: .curveEaseOut, animations: { _ in
                self.view.layoutIfNeeded()
            }, completion: { complete in
                
            })
        }
    }
    
    
    func profileTapped() {
        guard let profileVC = Utils.vcWithNameFromStoryboardWithName("inviteStream", storyboardName: "InviteStream") as? InviteStreamViewController else {
            return
        }
        self.present(profileVC, animated: true, completion: nil)
    }

    func closeTapped() {
        let _ = self.navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func addToStreamTapped(_ sender: Any) {
        guard let addVideosVC = Utils.vcWithNameFromStoryboardWithName("addVideos", storyboardName: "AddVideos") as? AddVideosViewController else {
            return
        }
        self.present(addVideosVC, animated: true, completion: nil)
    }
	@IBAction func chatInputActionTriggered(_ sender: UITextField) {
		if let text = sender.text {
			viewModel.send(chatMessage: text)
		}
        
        //reset textfields
        accessoryView.textField.text = nil
        chatInputTextField.text = nil
        
        //dismiss keyboard
        accessoryView.textField.resignFirstResponder()
        chatInputTextField.resignFirstResponder()
        
	}
	
	fileprivate func getVideoID(from url: URL) -> String? {
		guard let queries = url.query?.components(separatedBy: "&") else {
			return nil
		}
		for queryString in queries {
			let query = queryString.components(separatedBy: "=")
			if query.count > 1 && query[0] == "v" {
				return query[1]
			}
		}
		return nil
	}

}

extension StreamViewController: StreamViewModelDelegate {
	func userCountChanged(toCount count: Int) {
		userCountLabel.text = "\(count) Users"
	}
	
	func recieved(message: Message, for position: Int) {
		chatTableView.insertRows(at: [IndexPath(row: position, section: 0)], with: .automatic)
	}
	
	func recievedUpdate(forCurrentVideoID currentVideoID: String) {
		var playerID: String?
		if let playerURL = playerView.videoUrl() {
			playerID = getVideoID(from: playerURL)
		}
		if playerView.videoUrl() == nil || currentVideoID != playerID {
			DispatchQueue.main.async { //TODO: hide controls if participant
				self.playerView.load(withVideoId: currentVideoID, playerVars: [
					"playsinline" : 1,
					"modestbranding" : 1,
					"showinfo" : 0,
					"controls" : 1,
					])
			}
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
	
	func recievedUpdate(forIsBuffering isBuffering: Bool) {
		if isBuffering && playerView.playerState() == .playing {
			playerView.pauseVideo()
		}
	}
	
	func recievedUpdate(forPlaytime playtime: Float) {
		if abs(playtime - playerView.currentTime()) > viewModel.maximumDesyncTime {
			playerView.seek(toSeconds: playtime, allowSeekAhead: true)
		}
	}
	
	func streamEnded() {
		playerView.pauseVideo()
		 // TODO: Logic for displaying end stream popup
		print("stream ended")
	}
}

extension StreamViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell") as? ChatTableViewCell else {
			return UITableViewCell()
		}
		let message = viewModel.messages[indexPath.row]
		cell.nameLabel.text = nil
		cell.messageLabel.text = nil
		cell.profileImageView.image = nil
		FacebookDataManager.sharedInstance.fetchInfoForUser(withID: message.subjectID) { error, user in
			cell.nameLabel.text = user?.name
			if let message = message as? ChatMessage {
				cell.messageLabel.text = message.content
			}
			else if let message = message as? ParticipantMessage {
				cell.messageLabel.text = message.isJoining ? "joined the stream." : "left the stream."
			}
			user?.fetchProfileImage { error, image in
				cell.profileImageView.image = image
			}
		}
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.messages.count
	}
	
	
}

extension StreamViewController: YTPlayerViewDelegate {
    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {
		if viewModel.isHost {
			viewModel.send(currentPlayTime: playerView.currentTime())
		}
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
		if !viewModel.isHost {
			playerView.playVideo()
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
			if viewModel.isHost {
				viewModel.send(playState: false)
			}
            break
        case .buffering:
			if viewModel.isHost, let url = playerView.videoUrl(), let id = getVideoID(from: url) {
				viewModel.send(currentVideoID: id)
				viewModel.send(isBuffering: true)
			}
        case .playing:
            self.playPauseButton.setTitle("⏸", for: .normal)
            self.isPlaying = true
			if viewModel.isHost {
				viewModel.send(isBuffering: false)
				viewModel.send(playState: true)
			}
			else if !viewModel.hostPlaying {
				playerView.pauseVideo()
			}
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

extension StreamViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        chatInputActionTriggered(textField) //send the chat
        visualEffectView.isHidden = true
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        visualEffectView.isHidden = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        visualEffectView.isHidden = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        
        return true
    }
}
