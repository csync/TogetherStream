//
//  StreamViewController.swift
//  Stormtrooper
//
//  Created by Nathan Hekman on 11/23/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class StreamViewController: UIViewController {
    // MARK: - Outlets
    
    @IBOutlet weak var playerView: YTPlayerView!
    @IBOutlet weak var playerContainerView: UIView!
	@IBOutlet weak var chatInputTextField: UITextField!
	@IBOutlet weak var chatTableView: UITableView!
	@IBOutlet weak var userCountLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var queueView: UIView!
    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerArrowImageView: UIImageView!
    @IBOutlet weak var headerViewButton: UIButton!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var dismissView: UIView!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var videoSubtitleLabel: UILabel!
    @IBOutlet weak var queueTableView: UITableView!
    @IBOutlet weak var blockClicksButton: UIButton!
    
    // MARK: - Exposed Properties
    
    /// Exposed stream object to be set by other view controllers.
    var stream: Stream? {
        get {
            return viewModel.stream
        }
        set {
            viewModel.stream = newValue
        }
    }
    
    /// Exposed video queue to be set by other view controllers.
    var videoQueue: [Video]? {
        get {
            return viewModel.videoQueue
        }
        set {
            viewModel.videoQueue = newValue
        }
    }
    
    /// Exposed whether the current user is hosting the stream.
    var isHost: Bool {
        return viewModel.isHost
    }
    
    // MARK: - Contraints

    /// The original height of the header view.
    private var originalHeaderViewHeight: CGFloat = 0
    /// The original frame of the player view.
    private var originalPlayerViewFrame: CGRect = CGRect.zero
    /// The original constraints of the player view.
    private var originalPlayerViewConstraints: [NSLayoutConstraint] = []
    /// The contraints of the player view when it is in landscape.
    private var rotatedPlayerViewConstraints: [NSLayoutConstraint] = []
    
    // MARK: - Constants
    
    /// The frame of the close stream button.
    private let closeButtonFrame = CGRect(x: 0, y: 0, width: 17, height: 17)
    /// The frame of the invite to stream button.
    private let profileButtonFrame = CGRect(x: 0, y: 0, width: 19, height: 24)
    /// The length of the show/hide header animation in seconds.
    private let headerViewAnimationDuration: TimeInterval = 0.3
    /// The tag of the chat table.
    fileprivate let chatTableTag = 0
    /// The tag of the queue table.
    fileprivate let queueTableTag = 1
    /// The variables for the host player view.
    fileprivate let hostPlayerVariables = [
        "playsinline" : 1,
        "modestbranding" : 1,
        "showinfo" : 0,
        "controls" : 1,
        "origin" : "http://www.youtube.com"
        ] as [String : Any]
    /// The variables for the participant player view.
    fileprivate let participantPlayerVariables = [
        "playsinline" : 1,
        "modestbranding" : 1,
        "showinfo" : 0,
        "controls" : 0,
        "origin" : "http://www.youtube.com"
        ] as [String : Any]
    /// TODO: THIS IS USED FOR CHAT AND QUEUE
    /// The estimated height of a chat cell.
    fileprivate let estimatedChatCellHeight: CGFloat = 56
	
    
    // MARK: - Private Properties
    
    // TODO: Remove or move to viewModel
    fileprivate var isPlaying = false
    
    /// The model for the objects in this view.
    fileprivate let viewModel = StreamViewModel()
    
    // Accessory view shown above keyboard while chatting.
    fileprivate var accessoryView: ChatTextFieldAccessoryView!
    
    /// The direction the player is rotated to.
    ///
    /// - left: Rotated to the left.
    /// - right: Rotated to the right.
    /// - portrait: In portait mode.
    private enum PlayerDirection {
        case left
        case right
        case portrait
    }
    /// The current player direction.
    private var playerDirection: PlayerDirection = .portrait
    
    /// Whether the player view was previously setup
    private var didPreviouslySetupPlayerView: Bool = false
    
    /// Whether the status bar is previously hidden.
    private var statusBarHidden: Bool = false
    
    /// Whether the status bar should should be hidden.
    override var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }
    
    /// Specifies the animation style to use for hiding and showing the status bar for the view controller.
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }

    // MARK: - Lifecyle Events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trackScreenView()
        viewModel.delegate = self
		
        setupNavigationItems()
        setupChatTableView()
        setupQueueTableView()
        setupPlayerView()
        setupChatTextFieldView()
        setupProfilePictures()
        setupViewForHostOrParticipant()
        saveConstraints()
        
        NotificationCenter.default.addObserver(self, selector: #selector(StreamViewController.deviceDidRotate), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.setAnimationsEnabled(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupPlayerViewFrame()
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		if isBeingDismissed {
			NotificationCenter.default.removeObserver(self)
		}
	}
    
    // MARK: - Helper methods
    
    /// Set the navigation items for this view controller.
    private func setupNavigationItems() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    /// Sets up the frame of the player view.
    private func setupPlayerViewFrame() {
        if !didPreviouslySetupPlayerView {
            originalPlayerViewFrame = playerContainerView.frame
            saveOriginalPlayerViewFrame()
            didPreviouslySetupPlayerView = true
        }
    }
    
    /// TODO: ?
    private func saveOriginalPlayerViewFrame() {
        NSLayoutConstraint.deactivate(rotatedPlayerViewConstraints)
        let constraint1 = NSLayoutConstraint(item: self.playerContainerView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0.0)
        let constraint2 = NSLayoutConstraint(item: self.playerContainerView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.headerView, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0.0)
        let constraint3 = NSLayoutConstraint(item: self.playerContainerView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0.0)
        let constraint4 = NSLayoutConstraint(item: self.playerContainerView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0.0)
        let constraint5 = NSLayoutConstraint(item: self.playerContainerView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 211)
        let constraintArray = [constraint1, constraint2, constraint3, constraint4, constraint5]
        originalPlayerViewConstraints = constraintArray
        NSLayoutConstraint.activate(originalPlayerViewConstraints)
    }
    
    /// TODO: ?
    private func addRotatingConstraints() {
        NSLayoutConstraint.deactivate(originalPlayerViewConstraints)
        let screenFrame = UIScreen.main.bounds
        let constraint1 = NSLayoutConstraint(item: self.playerContainerView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: screenFrame.height)
        let constraint2 = NSLayoutConstraint(item: self.playerContainerView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: screenFrame.width)
        let constraint3 = NSLayoutConstraint(item: self.playerContainerView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0.0)
        let constraint4 = NSLayoutConstraint(item: self.playerContainerView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0.0)
        let constraintArray = [constraint1, constraint2, constraint3, constraint4]
        rotatedPlayerViewConstraints = constraintArray
        NSLayoutConstraint.activate(rotatedPlayerViewConstraints)
    }
    

    /// Sets up the view depending on whether the user is the host or participant of the stream.
    private func setupViewForHostOrParticipant() {
        if viewModel.isHost { //host-- can view queue, can end stream, can invite people
            // Show header expansion option
            headerArrowImageView.isHidden = false
            headerViewButton.isHidden = false
            
            // Set bar button items and their actions programmatically
            let closeButton = UIButton(type: .custom)
            closeButton.setImage(UIImage(named: "xStream"), for: .normal)
            closeButton.frame = closeButtonFrame
            closeButton.addTarget(self, action: #selector(StreamViewController.closeTapped), for: .touchUpInside)
            let item1 = UIBarButtonItem(customView: closeButton)
            
            // Show invite to stream button
            let profileButton = UIButton(type: .custom)
            profileButton.setImage(UIImage(named: "inviteIcon"), for: .normal)
            profileButton.frame = profileButtonFrame
            profileButton.addTarget(self, action: #selector(StreamViewController.inviteTapped), for: .touchUpInside)
            let item2 = UIBarButtonItem(customView: profileButton)
            
            navigationItem.setLeftBarButtonItems([item1], animated: false)
            navigationItem.setRightBarButtonItems([item2], animated: false)
            
            // Set inital video
            if videoQueue?.count ?? 0 > 0, let firstVideo = videoQueue?[0] {
                viewModel.send(currentVideoID: firstVideo.id)
            }
        }
        else { //participant-- cannot view queue, can't end stream, can't invite people
            // Hide header expansion option
            headerArrowImageView.isHidden = true
            headerViewButton.isHidden = true
            
            //Set bar button items and their actions programmatically
            let closeButton = UIButton(type: .custom)
            closeButton.setImage(UIImage(named: "back_stream"), for: .normal)
            closeButton.frame = closeButtonFrame
            closeButton.addTarget(self, action: #selector(StreamViewController.closeTapped), for: .touchUpInside)
            let item1 = UIBarButtonItem(customView: closeButton)
            
            navigationItem.setLeftBarButtonItems([item1], animated: false)
        }
        // Set title
        navigationItem.title = stream?.name
    }
    
    /// Adds a textfield view above keyboard when user starts typing in chat.
    private func setupChatTextFieldView() {
        // New instance of accessory view
        accessoryView = ChatTextFieldAccessoryView.instanceFromNib()
        
        // Set delegates of text fields
        accessoryView.textField.delegate = self
        chatInputTextField.delegate = self
        
        // Add selector to dismiss and when editing to sync up both textfields
        accessoryView.sendButton.addTarget(self, action: #selector(StreamViewController.chatInputActionTriggered), for: .touchUpInside)
        chatInputTextField.addTarget(self, action: #selector(StreamViewController.chatEditingChanged), for: [.editingChanged, .editingDidEnd])
        accessoryView.textField.addTarget(self, action: #selector(StreamViewController.accessoryViewEditingChanged), for: [.editingChanged, .editingDidEnd])
        
        // Actually set accessory view
        chatInputTextField.inputAccessoryView = accessoryView
        
        
    }
    
    /// Show current user's profile picture.
    private func setupProfilePictures() {
        FacebookDataManager.sharedInstance.fetchProfilePictureForCurrentUser() {error, image in
            if let image = image {
                DispatchQueue.main.async {
                    self.profileImageView.image = image
                    self.accessoryView.profileImageView.image = image
                }
            }
        }
    }
    
    /// Sets up the chat table view.
    private func setupChatTableView() {
        chatTableView.register(UINib(nibName: "ChatMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "chatMessage")
        chatTableView.register(UINib(nibName: "ChatEventTableViewCell", bundle: nil), forCellReuseIdentifier: "chatEvent")
        
    }
    
    /// Sets up the queue table view.
    private func setupQueueTableView() {
        queueTableView.register(UINib(nibName: "VideoQueueTableViewCell", bundle: nil), forCellReuseIdentifier: "queueCell")
    }
    
    /// Saves the needed constraints.
    private func saveConstraints() {
        originalHeaderViewHeight = headerViewHeightConstraint.constant
    }
    
    /// Sets up the player view.
    private func setupPlayerView() {
        playerView.backgroundColor = UIColor.white
        playerView.delegate = self
        // Load the inital video.
		if viewModel.isHost, let queue = viewModel.videoQueue, queue.count > 0 {
            // TODO: ?
            blockClicksButton.isHidden = true
            updateView(forVideoWithID: queue[0].id)
			playerView.load(withVideoId: queue[0].id, playerVars: hostPlayerVariables)
            viewModel.currentVideoIndex = 0
		}
        else if !viewModel.isHost, let queue = viewModel.videoQueue, queue.count > 0{
            blockClicksButton.isHidden = false //prevent user from playing/pausing video as participant
            updateView(forVideoWithID: queue[0].id)
            playerView.load(withVideoId: queue[0].id, playerVars: participantPlayerVariables)
            viewModel.currentVideoIndex = 0
        }
		
    }
    
    
    /// Copy text from main screen chat input textfield to accessory view textfield
    /// when editing changes or ends.
    ///
    /// - Parameter textField: The text field that changed.
    @objc private func chatEditingChanged(textField: UITextField) {
        accessoryView.textField.text = chatInputTextField.text
        
    }
    
    /// Copy text from accessory view textfield to main screen chat input textfield
    /// when editing changes or ends.
    ///
    /// - Parameter textField: The text field that changed.
    @objc private func accessoryViewEditingChanged(textField: UITextField) {
        chatInputTextField.text = accessoryView.textField.text
        
    }
    
    /// Dismisses accessory view and keyboard.
    private func cancelChatTapped() {
        accessoryView.textField.resignFirstResponder()
        chatInputTextField.resignFirstResponder()
    }
    
    /// On tapping dismiss chat, dismiss chat view and keyboard.
    ///
    /// - Parameter sender: The button tapped.
    @IBAction func dismissViewTapped(_ sender: Any) {
        Utils.sendGoogleAnalyticsEvent(withCategory: "Stream", action: "SelectedDismissChat")
        //dismiss view tapped, so dismiss keyboard if shown
        cancelChatTapped()
    }
    
    /// On tapping rotate player, rotate to either expanded or portait view.
    ///
    /// - Parameter sender: The button tapped.
    @IBAction func expandButtonTapped(_ sender: Any) {
        Utils.sendGoogleAnalyticsEvent(withCategory: "Stream", action: "SelectedExpandVideo")
        if statusBarHidden {
            returnPlayerViewToPortrait()
        }
        else {
            rotatePlayerView(byAngle: CGFloat(M_PI_2))
        }
    }
    
    
    /// On device rotation, rotate the player view.
    @objc private func deviceDidRotate() {
        Utils.sendGoogleAnalyticsEvent(withCategory: "Stream", action: "RotatedScreen")
        if navigationController?.visibleViewController == self {
            // TODO: Explain
            switch UIDevice.current.orientation {
            case .landscapeLeft:
                print("Landscape Left")
                if !statusBarHidden {
                    playerDirection = .left
                    rotatePlayerView(byAngle: CGFloat(M_PI_2))
                }
                if playerDirection == .right {
                    returnPlayerViewToPortrait()
                    playerDirection = .left
                    rotatePlayerView(byAngle: CGFloat(M_PI_2))
                }
            case .landscapeRight:
                if !statusBarHidden {
                    print("Landscape Right")
                    playerDirection = .right
                    rotatePlayerView(byAngle: CGFloat(-M_PI_2))
                }
                if playerDirection == .left {
                    returnPlayerViewToPortrait()
                    playerDirection = .right
                    rotatePlayerView(byAngle: CGFloat(-M_PI_2))
                }
            case .portrait:
                print("Portrait")
                if statusBarHidden {
                    playerDirection = .portrait
                    returnPlayerViewToPortrait()
                }
            default:
                break
            }
        }
    }
    
    /// Rotates the player view by the angle provided.
    ///
    /// - Parameter angle: The amount to rotate the player view by, in radians.
    private func rotatePlayerView(byAngle angle: CGFloat) {
        // TODO: explain
        self.statusBarHidden = true
        NSLayoutConstraint.deactivate(originalPlayerViewConstraints)
        self.navigationController?.navigationBar.isHidden = true
        DispatchQueue.main.async {
            self.playerContainerView.transform = CGAffineTransform(rotationAngle: angle)
            self.setNeedsStatusBarAppearanceUpdate()
            self.addRotatingConstraints()
            self.view.updateConstraintsIfNeeded()
        }
    }
    
    /// Returns the player view to the portrait orientation.
    private func returnPlayerViewToPortrait() {
        self.statusBarHidden = false
        NSLayoutConstraint.deactivate(rotatedPlayerViewConstraints)
        self.navigationController?.navigationBar.isHidden = false
        DispatchQueue.main.async {
            self.playerContainerView.transform = CGAffineTransform.identity
            self.setNeedsStatusBarAppearanceUpdate()
            self.saveOriginalPlayerViewFrame()
            self.playerContainerView.frame = self.originalPlayerViewFrame //reset playerview if portrait
            self.view.updateConstraintsIfNeeded()
        }
    }
    
    /// On header tapped, show or hide queue.
    ///
    /// - Parameter sender: The button tapped.
    @IBAction func headerTapped(_ sender: Any) {
        UIView.setAnimationsEnabled(true) //fix for animations breaking
        
        if queueView.isHidden {
            Utils.sendGoogleAnalyticsEvent(withCategory: "Stream", action: "PressedHeader", label: "ExpandedQueue")
            headerViewHeightConstraint.constant = originalHeaderViewHeight + queueView.frame.height
            UIView.animate(withDuration: headerViewAnimationDuration, delay: 0, options: .curveEaseOut, animations: { _ in
                self.view.layoutIfNeeded()
                //rotate arrow
                self.headerArrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            }, completion: { complete in
                self.queueView.isHidden = false
                if let currentVideoIndex = self.viewModel.currentVideoIndex {
                    let currentVideoIndexPath = IndexPath(row: currentVideoIndex, section: 0)
                    self.queueTableView.scrollToRow(at: currentVideoIndexPath, at: .top, animated: true)
                }
            })
        }
        else {
            Utils.sendGoogleAnalyticsEvent(withCategory: "Stream", action: "PressedHeader", label: "CollapsedQueue")
            self.queueView.isHidden = true
            headerViewHeightConstraint.constant = originalHeaderViewHeight
            UIView.animate(withDuration: headerViewAnimationDuration, delay: 0, options: .curveEaseOut, animations: { _ in
                self.view.layoutIfNeeded()
                //rotate arrow
                self.headerArrowImageView.transform = CGAffineTransform.identity
            }, completion: { complete in
            })
        }
    }
    
    
    /// On invite tapped, present the "Invite" screen.
    @objc private func inviteTapped() {
        Utils.sendGoogleAnalyticsEvent(withCategory: "Stream", action: "SelectedInvite")
        guard let inviteVC = Utils.vcWithNameFromStoryboardWithName("inviteStream", storyboardName: "InviteStream") as? InviteStreamViewController else {
            return
        }
        inviteVC.navigationItem.title = "Invite to Stream"
        inviteVC.canInviteToStream = true
        inviteVC.isCreatingStream = false
        inviteVC.stream = stream
        navigationController?.pushViewController(inviteVC, animated: true)
    }
    
    /// On close stream tapped, present option for host to end their stream.
    /// - Note: `leaveStream()` is not called directly since the callback
    /// would be set to be the button due to Obj-C bridging.
    @objc private func closeTapped() {
        leaveStream()
    }

    /// Leave stream if participant, present option to end stream if host.
    ///
    /// - Parameter hostDidConfirm: Callback executed if host confirms to end stream.
    func leaveStream(hostDidConfirm: ((Void) -> Void)? = nil) {
        if viewModel.isHost {
            Utils.sendGoogleAnalyticsEvent(withCategory: "Stream", action: "LeftStream", label: "host")
            leaveStreamAsHost(hostDidConfirm: hostDidConfirm)
        } else {
            Utils.sendGoogleAnalyticsEvent(withCategory: "Stream", action: "LeftStream", label: "participant")
            leaveStreamAsParticipant()
        }
    }
    
    /// Presents option to end stream and pops to root screen if confirmed.
    ///
    /// - Parameter hostDidConfirm: Callback executed if host confirms to end stream.
    private func leaveStreamAsHost(hostDidConfirm: ((Void) -> Void)? = nil) {
        // define callback to end the stream
        let endStream = {
            self.viewModel.endStream()
            let _ = self.navigationController?.popToRootViewController(animated: true)
            hostDidConfirm?()
        }
        
        // present popup with default user profile picture
        let popup = PopupViewController.instantiate(
            titleText: stream?.name.uppercased() ?? "MY STREAM",
            image: #imageLiteral(resourceName: "profile_85"),
            messageText: stream?.name ?? "",
            descriptionText: "Would you like to end your stream?",
            primaryButtonText: "END STREAM",
            secondaryButtonText: "Cancel",
            completion: endStream
        )
        present(popup, animated: true)
        
        // update popup with user profile picture
        FacebookDataManager.sharedInstance.fetchProfilePictureForCurrentUser { error, image in
            if let image = image {
                DispatchQueue.main.async {
                    popup.image = image
                }
            }
        }
    }
    
    /// Pops to root screen.
    private func leaveStreamAsParticipant() {
        let _ = navigationController?.popToRootViewController(animated: true)
    }

    /// On "Add Videos" tapped, present the "Add Videos" screen.
    ///
    /// - Parameter sender: The button tapped.
    @IBAction func addToStreamTapped(_ sender: Any) {
        Utils.sendGoogleAnalyticsEvent(withCategory: "Stream", action: "SelectedAddVideos")
        guard let addVideosVC = Utils.vcWithNameFromStoryboardWithName("addVideos", storyboardName: "AddVideos") as? AddVideosViewController else {
            return
        }
        addVideosVC.stream = stream
        addVideosVC.isCreatingStream = false
        addVideosVC.delegate = self
        navigationController?.pushViewController(addVideosVC, animated: true)
    }
    
    /// On triggering send chat message, send the message and reset the input fields.
    @objc fileprivate func chatInputActionTriggered() {
        let textToSend = chatInputTextField.text ?? accessoryView.textField.text ?? ""
        guard textToSend.characters.count > 0 else { return }

        Utils.sendGoogleAnalyticsEvent(withCategory: "Stream", action: "SelectedSendText")

        // Send chat
        viewModel.send(chatMessage: textToSend)

        // Reset textfields
        accessoryView.textField.text = nil
        chatInputTextField.text = nil

        // Dismiss keyboard
        accessoryView.textField.resignFirstResponder()
        chatInputTextField.resignFirstResponder()

        // Hide keyboard views
        updateView(forIsKeyboardShowing: false)

        // Scroll table view down
        if viewModel.messages.count > 0 {
            let indexPath = IndexPath(item: viewModel.messages.count - 1, section: 0)
            chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
	}
    
    /// On pressing the edit button, toggle edit mode on the queue.
    ///
    /// - Parameter sender: The buton pressed.
    @IBAction func didToggleQueueEdit(_ sender: UIButton) {
        if queueTableView.isEditing {
            Utils.sendGoogleAnalyticsEvent(withCategory: "Stream", action: "ToggleQueueEdit", label: "Finished")
            queueTableView.isEditing = false
            sender.setTitle("Edit", for: .normal)
        }
        else {
            Utils.sendGoogleAnalyticsEvent(withCategory: "Stream", action: "ToggleQueueEdit", label: "Started")
            queueTableView.isEditing = true
            sender.setTitle("Done", for: .normal)
        }
    }
	
	/// Parses the given URL to extract the video ID.
	///
	/// - Parameter url: The URL to parse.
	/// - Returns: The video ID if found, nil otherwise.
    /// - Note: Expects ID to be found in the query parameter "v".
	fileprivate func extractVideoID(from url: URL) -> String? {
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
    
    /// Updates the displayed video info to the video with the given ID.
    ///
    /// - Parameter id: The ID of the video to be displayed.
    fileprivate func updateView(forVideoWithID id: String) {
        // Fetch video info
        viewModel.fetchVideo(withID: id) {[weak self] error, video in
            DispatchQueue.main.async {
                if let video = video {
                    // Set title, channel title and view count
                    self?.videoTitleLabel.text = video.title
                    var subtitle = video.channelTitle
                    if let viewCount = video.viewCount {
                        subtitle += " - \(viewCount) views"
                    }
                    self?.videoSubtitleLabel.text = subtitle
                }
                else {
                    // Just display default text
                    self?.videoTitleLabel.text = "-"
                    self?.videoSubtitleLabel.text = "-"
                }
            }
        }
    }
    
    /// Configures the highlight of the given row.
    ///
    /// - Parameters:
    ///   - row: The row that should be configured.
    ///   - highlighted: Whether to set or remove the highlight.
    fileprivate func setHighlightForVideo(at row: Int, highlighted: Bool) {
        // update the previous video (i.e. whether to hide its separator)
        let previousIndexPath = IndexPath(row: row-1, section: 0)
        let previousVideoCell = queueTableView.cellForRow(at: previousIndexPath) as? VideoQueueTableViewCell
        previousVideoCell?.isPreviousVideo = highlighted
        
        // update the current video (i.e. whether to highlight it)
        let indexPath = IndexPath(row: row, section: 0)
        let videoCell = queueTableView.cellForRow(at: indexPath) as? VideoQueueTableViewCell
        videoCell?.isCurrentVideo = highlighted
    }
    
    /// Deletes the video at the given index path and updates the stream state.
    ///
    /// - Parameter indexPath: The index path of the video to delete.
    fileprivate func deleteVideo(at indexPath: IndexPath) {
        // Get the indexes of the effected videos
        guard let currentVideoIndex = viewModel.currentVideoIndex else { return }
        let previousIndexPath = IndexPath(row: indexPath.row - 1, section: 0)
        let nextIndexPath = IndexPath(row: indexPath.row + 1, section: 0)
        
        // Deleted the previous video
        if indexPath.row == currentVideoIndex - 1 {
            let previousCell = queueTableView.cellForRow(at: previousIndexPath)
            let previousVideoCell = previousCell as? VideoQueueTableViewCell
            previousVideoCell?.isPreviousVideo = true
        }
        
        // Deleted the current video
        if indexPath.row == currentVideoIndex {
            guard let videoQueue = viewModel.videoQueue else { return }
            setHighlightForVideo(at: nextIndexPath.row, highlighted: true)
            viewModel.currentVideoIndex = nextIndexPath.row
            let nextVideoId = videoQueue[nextIndexPath.row].id
            playerView.cueVideo(byId: nextVideoId, startSeconds: 0, suggestedQuality: .default)
            playerView.playVideo()
        }
        
        // Remove deleted video from queue and view model
        queueTableView.beginUpdates()
        queueTableView.deleteRows(at: [indexPath], with: .automatic)
        viewModel.videoQueue?.remove(at: indexPath.row)
        // Update the current video index if needed
        if currentVideoIndex > indexPath.row {
            viewModel.currentVideoIndex = currentVideoIndex - 1
        }
        queueTableView.endUpdates()
    }
    
    /// Update view depending on whether the keyboard is visible.
    ///
    /// - Parameter isKeyboardShowing: Whether the keyboard is visible.
    fileprivate func updateView(forIsKeyboardShowing isKeyboardShowing: Bool) {
        if isKeyboardShowing {
            visualEffectView.isHidden = false
            dismissView.isHidden = false
        } else {
            visualEffectView.isHidden = true
            dismissView.isHidden = true
        }
    }
}

// MARK: - StreamViewModelDelegate
extension StreamViewController: StreamViewModelDelegate {
	/// On user count changing, update the displayed count.
	///
	/// - Parameter count: The new user count.
	func userCountChanged(toCount count: Int) {
		userCountLabel.text = "\(count)"
	}
	
	/// On receiving a message, add it to the chat table and scroll
    /// to the bottom.
	///
	/// - Parameters:
	///   - message: The message received.
	///   - position: The position the message should be in.
	func received(message: Message, for position: Int) {
        chatTableView.beginUpdates()
        chatTableView.insertRows(at: [IndexPath(row: position, section: 0)], with: .automatic)
        chatTableView.scrollTableViewToBottom(animated: false)
        chatTableView.endUpdates()
	}
    
    /// When the oldest message is removed from the model, remove it from the view.
    func removedOldestMessage() {
        chatTableView.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
	
	/// On current video changing, load new video and update view.
	///
	/// - Parameter currentVideoID: The ID of the new current video.
	func receivedUpdate(forCurrentVideoID currentVideoID: String) {
        // Get the player's video ID
		var playerID: String?
		if let playerURL = playerView.videoUrl() {
			playerID = extractVideoID(from: playerURL)
		}
        // Change to new video if no player video or if player video is different
		if playerView.videoUrl() == nil || currentVideoID != playerID {
            updateView(forVideoWithID: currentVideoID)
			DispatchQueue.main.async {
                // Only participants will receive updates
                self.playerView.load(withVideoId: currentVideoID, playerVars: self.participantPlayerVariables)
			}
		}
	}
	
	/// On play state change, pause or play the video.
	///
	/// - Parameter isPlaying: Whether the video is playing or paused.
	func receivedUpdate(forIsPlaying isPlaying: Bool) {
		if isPlaying && playerView.playerState() != .playing {
            DispatchQueue.main.async {
                self.playerView.playVideo()
            }
		}
		else if !isPlaying && playerView.playerState() != .paused {
            DispatchQueue.main.async {
                self.playerView.pauseVideo()
            }
		}
	}
	
	/// If host is buffering, pause the video.
	///
	/// - Parameter isBuffering: Whether the host is buffering.
	func receivedUpdate(forIsBuffering isBuffering: Bool) {
		if isBuffering && playerView.playerState() == .playing {
            DispatchQueue.main.async {
                self.playerView.pauseVideo()
            }
		}
	}
	
	/// If the playtime is out of sync, jump to the host's playtime.
	///
	/// - Parameter playtime: The host playtime in seconds.
	func receivedUpdate(forPlaytime playtime: Float) {
		if abs(playtime - playerView.currentTime()) > viewModel.maximumDesyncTime {
            DispatchQueue.main.async {
                self.playerView.seek(toSeconds: playtime, allowSeekAhead: true)
            }
		}
	}
	
	/// On stream ending, present notification and pop to root screen.
	func streamEnded() {
        Utils.sendGoogleAnalyticsEvent(withCategory: "Stream", action: "ReceivedStreamEnded")
        // Make sure player doesn't keep playing
        playerView.pauseVideo()
        
        // Present popup with default user profile picture
		let popup = PopupViewController.instantiate(
            titleText: stream?.name.uppercased() ?? "",
            image: #imageLiteral(resourceName: "profile_85"),
            messageText: (stream?.name ?? ""),
            descriptionText: "This stream has ended.",
            primaryButtonText: "DISMISS",
            completion: { _ = self.navigationController?.popViewController(animated: true) }
        )
        present(popup, animated: true)
        
        // Update popup with host profile picture from Facebook
        if let hostFacebookID = stream?.hostFacebookID {
            FacebookDataManager.sharedInstance.fetchInfoForUser(withID: hostFacebookID) { error, user in
                guard error == nil else { return }
                user?.fetchProfileImage { error, image in
                    guard error == nil else { return }
                    if let image = image {
                        popup.image = image
                    }
                }
            }
        }
	}
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension StreamViewController: UITableViewDelegate, UITableViewDataSource {
    /// Dequeues and configures the cell for the given path.
    ///
    /// - Parameters:
    ///   - tableView: The table requesting the cell.
    ///   - indexPath: The path of the cell.
    /// - Returns: The cell to display.
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView.tag {
        case chatTableTag: return cellFor(chatTableView: tableView, at: indexPath)
        case queueTableTag: return cellFor(queueTableView: tableView, at: indexPath)
        default: return UITableViewCell()
        }
	}
    
    /// Sets the height to be automatic based on constraints.
    ///
    /// - Parameters:
    ///   - tableView: The table requesting the height.
    ///   - indexPath: The index path of the row the request is for.
    /// - Returns: The height of the cell.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    /// Sets the height to be based off the cell constant.
    ///
    /// - Parameters:
    ///   - tableView: The table requesting the height.
    ///   - indexPath: The index path of the row the request is for.
    /// - Returns: The height of the cell.
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return estimatedChatCellHeight
    }
    
    /// Determines if the selected row can be edited.
    ///
    /// - Parameters:
    ///   - tableView: The table view selected.
    ///   - indexPath: The index path of the selected row.
    /// - Returns: Whether the row can be edited.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch tableView.tag {
        case chatTableTag: return false
        case queueTableTag: return indexPath.row != viewModel.currentVideoIndex
        default: return false
        }
    }
    
    /// Commits the deletion of a cell by performing the delete.
    ///
    /// - Parameters:
    ///   - tableView: The table view edited.
    ///   - editingStyle: The style of editing.
    ///   - indexPath: The index path of the cell edited.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            Utils.sendGoogleAnalyticsEvent(withCategory: "Stream", action: "DeletedVideo")
            deleteVideo(at: indexPath)
        default: break
        }
    }
	
    /// Returns the number of rows for the section.
    ///
    /// - Parameters:
    ///   - tableView: The tableview requesting the number.
    ///   - section: The section the request is for.
    /// - Returns: The number of rows for the section.
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case chatTableTag: return viewModel.messages.count
        case queueTableTag: return viewModel.videoQueue?.count ?? 0
        default: return 0
        }
	}
    
    /// Allows the queue table cells to be moved.
    ///
    /// - Parameters:
    ///   - tableView: The table view asking if a row can be moved.
    ///   - indexPath: The index path of the requested row.
    /// - Returns: Whether the row can be moved.
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        switch tableView.tag {
        case chatTableTag: return false
        case queueTableTag: return true
        default: return false
        }
    }
    
    /// Moves the row from source index path to destination index path and updates
    /// the state of the stream.
    ///
    /// - Parameters:
    ///   - tableView: The table of the moving rows.
    ///   - sourceIndexPath: The index path of the row being moved.
    ///   - destinationIndexPath: The index path that the row is being moved to.
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        Utils.sendGoogleAnalyticsEvent(withCategory: "Stream", action: "ReorderedVideo")
        guard let currentVideoIndex = viewModel.currentVideoIndex,
            let video = viewModel.videoQueue?.remove(at: sourceIndexPath.row) else {
                return
        }
        viewModel.videoQueue?.insert(video, at: destinationIndexPath.row)
        
        // update the view model's current video index
        if sourceIndexPath.row == currentVideoIndex {
            // moved the current video
            viewModel.currentVideoIndex = destinationIndexPath.row
        } else if destinationIndexPath.row == currentVideoIndex {
            // moved a video to the current video's index
            viewModel.currentVideoIndex = destinationIndexPath.row + (sourceIndexPath.row > destinationIndexPath.row ? 1 : -1)
        } else if sourceIndexPath.row < currentVideoIndex, currentVideoIndex < destinationIndexPath.row {
            // moved a video from the left-side of the current video to the right-side
            viewModel.currentVideoIndex = currentVideoIndex - 1
        } else if sourceIndexPath.row > currentVideoIndex, currentVideoIndex > destinationIndexPath.row {
            // moved a video from the right-side of the current video to the left-side
            viewModel.currentVideoIndex = currentVideoIndex + 1
        }
    }
    
    /// Confirms move to proposed index path.
    ///
    /// - Parameters:
    ///   - tableView: The table of the moving rows.
    ///   - sourceIndexPath: The index path of the row being moved.
    ///   - proposedDestinationIndexPath: The proposed destination to move the row.
    /// - Returns: The destination of the moving row.
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return proposedDestinationIndexPath
    }
    
    /// Switches the current video to the one selected.
    ///
    /// - Parameters:
    ///   - tableView: The table view being selected.
    ///   - indexPath: The index path of the row that was selected.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard viewModel.currentVideoIndex != indexPath.row,
            let currentVideoIndex = viewModel.currentVideoIndex else {
                return
        }
         Utils.sendGoogleAnalyticsEvent(withCategory: "Stream", action: "SelectedVideoToPlay")
        setHighlightForVideo(at: currentVideoIndex, highlighted: false)
        setHighlightForVideo(at: indexPath.row, highlighted: true)
        viewModel.currentVideoIndex = indexPath.row
        playerView.cueVideo(byId: viewModel.videoQueue?[indexPath.row].id ?? "", startSeconds: 0, suggestedQuality: .default)
        playerView.playVideo()
    }
	
    /// Dequeues and configures the cell for the given path for the chat table.
    ///
    /// - Parameters:
    ///   - tableView: The table requesting the cell.
    ///   - indexPath: The path of the cell.
    /// - Returns: The cell to display.
    private func cellFor(chatTableView tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let messageCell = tableView.dequeueReusableCell(withIdentifier: "chatMessage") as? ChatMessageTableViewCell
        let eventCell = tableView.dequeueReusableCell(withIdentifier: "chatEvent") as? ChatEventTableViewCell
        
        let message = viewModel.messages[indexPath.row]
        
        // Fetch the info of the message author
        FacebookDataManager.sharedInstance.fetchInfoForUser(withID: message.subjectID) { error, user in
            // Configure cell based on type of message
            if let message = message as? ChatMessage {
                DispatchQueue.main.async {
                    messageCell?.messageLabel.text = message.content
                    messageCell?.nameLabel.text = user?.name
                }
            }
            else if let message = message as? ParticipantMessage {
                DispatchQueue.main.async {
                    eventCell?.messageLabel.text = message.isJoining ? " joined the stream." : " left the stream."
                    eventCell?.nameLabel.text = user?.name
                }
            }
            // Fetch the profile image of the message author
            user?.fetchProfileImage { error, image in
                DispatchQueue.main.async {
                    messageCell?.profileImageView.image = image
                    eventCell?.profileImageView.image = image
                }
            }
        }
        
        // Returns messageCell ?? eventCell ?? UITableViewCell()
        if message is ChatMessage, let messageCell = messageCell {
            return messageCell
        }
        else if message is ParticipantMessage, let eventCell = eventCell {
            return eventCell
        }
        else {
            return UITableViewCell()
        }
    }
    
    /// Dequeues and configures the cell for the given path for the queue table.
    ///
    /// - Parameters:
    ///   - tableView: The table requesting the cell.
    ///   - indexPath: The path of the cell.
    /// - Returns: The cell to display.
	private func cellFor(queueTableView tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "queueCell") as? VideoQueueTableViewCell,
            let video = viewModel.videoQueue?[indexPath.row],
            let currentVideoIndex = viewModel.currentVideoIndex else {
                return UITableViewCell()
        }
        
        // Don't reconfigure cell if it's already configured to the proper video
        guard cell.videoID != video.id else {
            return cell
        }
        
        cell.videoID = video.id
        cell.thumbnail = nil
        cell.title = video.title
        cell.channel = video.channelTitle
        cell.isPreviousVideo = (currentVideoIndex-1 == indexPath.row)
        cell.isCurrentVideo = (currentVideoIndex == indexPath.row)
        
        video.getMediumThumbnail {error, image in
            guard let image = image else { return }
            cell.thumbnail = image
        }
        
        return cell
    }
}

// MARK: - YTPlayerViewDelegate
extension StreamViewController: YTPlayerViewDelegate {
    /// On receiving a playtime update, send the current playtime if the host.
    ///
    /// - Parameters:
    ///   - playerView: The player sending the update.
    ///   - playTime: The sent play time of the playing video.
    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {
		if viewModel.isHost {
			viewModel.send(currentPlayTime: playerView.currentTime())
		}
    }
    
    /// On receiving an error, display the error.
    ///
    /// - Parameters:
    ///   - playerView: The player sending the error.
    ///   - error: The error that occured.
    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
        Utils.sendGoogleAnalyticsEvent(withCategory: "Stream", action: "ReceivedPlayerError", label: "\(error)")
        let alert = UIAlertController(title: "Received Error from Player", message: "\(error)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    /// Once the player is ready, play the video if the participant.
    ///
    /// - Parameter playerView: The player that became ready.
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
		if !viewModel.isHost {
			playerView.playVideo()
		}
    }
    
    /// On receiving a state update, update the view or send a message depending on the state
    /// and if the user is the host.
    ///
    /// - Parameters:
    ///   - playerView: The player sending the state update.
    ///   - state: The state of the player.
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        switch (state) {
        case .paused:
            isPlaying = false
			if viewModel.isHost {
				viewModel.send(playState: false)
			}
        case .buffering:
            // The buffering state is the only signal that the currently playing video changed
			if viewModel.isHost, let url = playerView.videoUrl(), let id = extractVideoID(from: url) {
                updateView(forVideoWithID: id)
				viewModel.send(currentVideoID: id)
				viewModel.send(isBuffering: true)
			}
        case .playing:
            isPlaying = true
			if viewModel.isHost {
				viewModel.send(isBuffering: false)
				viewModel.send(playState: true)
			}
			else if !viewModel.hostPlaying {
				playerView.pauseVideo()
			}
        case .ended:
            if viewModel.isHost {
                playNextVideo()
            }
        case .queued, .unknown, .unstarted:
            break
        }
    }
    
    /// Update the player to play the next video in the video queue.
    private func playNextVideo() {
        Utils.sendGoogleAnalyticsEvent(withCategory: "Stream", action: "NextVideoPlayed")
        // Make sure there's a queue and a current video
        guard let videoQueue = viewModel.videoQueue,
            let currentVideoIndex = viewModel.currentVideoIndex else { return }
        
        // Determine the next video
        let nextVideoIndex = currentVideoIndex < videoQueue.count - 1 ? currentVideoIndex + 1 : 0
        
        // Update video queue
        setHighlightForVideo(at: currentVideoIndex, highlighted: false)
        setHighlightForVideo(at: nextVideoIndex, highlighted: true)
        
        // Update the model
        viewModel.currentVideoIndex = nextVideoIndex
        
        // Play the next video
        let nextVideoID = videoQueue[nextVideoIndex].id
        playerView.cueVideo(byId: nextVideoID, startSeconds: 0, suggestedQuality: .default)
        playerView.playVideo()
    }
}

// MARK: - UITextFieldDelegate
extension StreamViewController: UITextFieldDelegate {
    /// On a text field returning, confirm return and send the chat message.
    ///
    /// - Parameter textField: The text field returning.
    /// - Returns: Whether the text field should return.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        chatInputActionTriggered() //send the chat
        return true
    }
    
    /// On a text field beginning to edit, update the view for the keyboard showing.
    ///
    /// - Parameter textField: The text field that's beginning to edit.
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.setAnimationsEnabled(true) //fix for animations breaking
        updateView(forIsKeyboardShowing: true)
    }
    
    /// On a text field finishing editing, update the view for the keyboard hiding.
    ///
    /// - Parameter textField: The text field that's finishing editing.
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateView(forIsKeyboardShowing: false)
    }
}

// MARK: - AddVideosDelegate
extension StreamViewController: AddVideosDelegate {
    /// Append the selected videos to the queue and update the view.
    ///
    /// - Parameter selectedVideos: The videos selected.
    func didAddVideos(selectedVideos: [Video]) {
        let videoQueue = viewModel.videoQueue ?? [Video]()
        viewModel.videoQueue = videoQueue + selectedVideos
        DispatchQueue.main.async {
            self.queueTableView.reloadData()
        }
    }
}
