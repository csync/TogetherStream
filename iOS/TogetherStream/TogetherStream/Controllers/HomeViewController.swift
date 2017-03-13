//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-ios
//

import UIKit
import Foundation
import Crashlytics

/// View controller for the "Home/Stream Invites" screen
class HomeViewController: UIViewController {
	@IBOutlet weak var streamsTableView: UITableView!
	
	/// The model for the objects in this view.
	fileprivate let viewModel = HomeViewModel()
    /// The facebook profile ID of the currently displayed user.
    private var facebookProfileID: String?
    // The size of the profile button.
    private let profileFrame = CGRect(x: 0, y: 0, width: 23, height: 23)
    // Inset to provide padding to the streams table view
    private let streamsTableViewInset = UIEdgeInsets(top: 9, left: 0, bottom: 0, right: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        trackScreenView()
        setupTableView()
        // Reset current user's stream in case the app was exited ungracefully while streaming.
		viewModel.resetCurrentUserStream()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        displayLoginIfNeeded()
        logUserWithCrashlytics()
        setupNavigationBar()
        setupNavigationItems()
        setupProfileButton()
        refreshStreams()
        UIView.setAnimationsEnabled(true)
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		viewModel.stopStreamsListening()
	}
    
    /// Set the navigation bar for all view controllers in the navigation stack.
    private func setupNavigationBar() {
        navigationController?.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "back_stream")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "back_stream")
        navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "WorkSans-Regular", size: 17) ?? UIFont.systemFont(ofSize: 17)
        ]
    }
    
    /// Set the navigation items for this view controller.
    private func setupNavigationItems() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    /// Sets up the profile button.
    private func setupProfileButton() {
        // Only set up if the profile has changed
        guard facebookProfileID != FacebookDataManager.sharedInstance.profile?.userID else { return }
        
        facebookProfileID = FacebookDataManager.sharedInstance.profile?.userID
        let profileButton = UIButton(type: .custom)
        profileButton.frame = profileFrame
        // Set the profile button's image to the user's profile pic
        FacebookDataManager.sharedInstance.fetchProfilePictureForCurrentUser() {error, image in
            DispatchQueue.main.async {
                if let image = image {
                    profileButton.setImage(image, for: .normal)
                    profileButton.layer.cornerRadius = profileButton.frame.width / 2
                    profileButton.clipsToBounds = true
                }
                else {
                    profileButton.setImage(#imageLiteral(resourceName: "Profile_50"), for: .normal)
                }
            }
        }
        
        profileButton.addTarget(self, action: #selector(HomeViewController.profileTapped), for: .touchUpInside)
        
        let profileButtonItem = UIBarButtonItem(customView: profileButton)
        navigationItem.rightBarButtonItem = profileButtonItem
    }
    
    /// Sets up the stream table view.
    private func setupTableView() {
        streamsTableView.register(UINib(nibName: "StreamTableViewCell", bundle: nil), forCellReuseIdentifier: "streamCell")
        streamsTableView.register(UINib(nibName: "NoStreamsTableViewCell", bundle: nil), forCellReuseIdentifier: "noStreamsCell")
        streamsTableView.contentInset = streamsTableViewInset
        
        // Sets up pull to refresh functionality.
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        streamsTableView.refreshControl = refreshControl
    }
    
    /// Shows the "Login" screen if not logged in.
    private func displayLoginIfNeeded() {
        if FacebookDataManager.sharedInstance.profile == nil {
            guard let loginVC = Utils.instantiateViewController(withIdentifier: "login", fromStoryboardNamed: "Login") as? LoginViewController else {
                return
            }
            present(loginVC, animated: true)
        }
    }
    
    /// Log the current user's id and name with Crashlytics to support detailed crash reports.
    /// (The current user's profile must not be nil.)
    func logUserWithCrashlytics() {
        if let profile = FacebookDataManager.sharedInstance.profile {
            Crashlytics.sharedInstance().setUserIdentifier(profile.userID)
            Crashlytics.sharedInstance().setUserName(profile.name)
        }
    }
    
    /// Fetches the latest stream invites.
    ///
    /// - Parameter callback: The callback called on completion.
    func refreshStreams(callback: ((Void) -> Void)? = nil) {
        viewModel.refreshStreams { error, streams in
            DispatchQueue.main.async {
                if let error = error {
                    let alert = UIAlertController(title: "Error Loading Streams", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true) {
                        callback?()
                    }
                }
                else {
                    self.streamsTableView.reloadData()
                    callback?()
                }
            }
        }
    }
    
    /// On pulled to refresh, refresh streams.
    ///
    /// - Parameter refreshControl: The refresh control that was pulled.
    @objc private func refresh(_ refreshControl: UIRefreshControl) {
        Utils.sendGoogleAnalyticsEvent(withCategory: "Home", action: "PulledRefresh")
        refreshStreams {
            DispatchQueue.main.async {
                refreshControl.endRefreshing()
            }
        }
    }
    
    /// On profile button tapped, show the "Profile" screen.
    @objc private func profileTapped() {
        Utils.sendGoogleAnalyticsEvent(withCategory: "Home", action: "ProfileTapped")
        guard let profileVC = Utils.instantiateViewController(withIdentifier: "profile", fromStoryboardNamed: "Profile") as? ProfileViewController else {
            return
        }
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    /// On the invite friends button tapped, show the "Invite Friends" screen.
    fileprivate func didSelectInviteFriends() {
        Utils.sendGoogleAnalyticsEvent(withCategory: "Home", action: "PressedInviteFriends")
        let activityViewController = UIActivityViewController(activityItems: [Utils.inviteMessage], applicationActivities: nil)
        DispatchQueue.main.async {
            self.present(activityViewController, animated: true)
        }
    }

    /// On start stream tapped, show the "Name Stream" screen.
    ///
    /// - Parameter sender: The button that was tapped.
    @IBAction func startStreamTapped(_ sender: Any) {
        Utils.sendGoogleAnalyticsEvent(withCategory: "Home", action: "PressedStartStream")
        guard let nameStreamVC = Utils.instantiateViewController(withIdentifier: "nameStream", fromStoryboardNamed: "NameStream") as? NameStreamViewController else {
            return
        }
        nameStreamVC.navigationItem.title = "New Stream"
        navigationController?.pushViewController(nameStreamVC, animated: true)
    }

}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    /// Returns the number of rows for the section.
    ///
    /// - Parameters:
    ///   - tableView: The tableview requesting the number.
    ///   - section: The section the request is for.
    /// - Returns: The number of rows for the section.
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfRows
	}
	
    /// Dequeues and configures the cell for the given path.
    ///
    /// - Parameters:
    ///   - tableView: The table requesting the cell.
    ///   - indexPath: The path of the cell.
    /// - Returns: The cell to display.
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == viewModel.numberOfRows - 1 {
            // Configure "No More Streams" cell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "noStreamsCell") as? NoStreamsTableViewCell else {
                return UITableViewCell()
            }
            cell.didSelectInviteFriends = {[unowned self] in self.didSelectInviteFriends()}
            cell.selectionStyle = .none
            return cell
        }
        
        // Configure "Stream" cell
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "streamCell") as? StreamTableViewCell else {
			return UITableViewCell()
		}
		let stream = viewModel.streams[indexPath.row]
		cell.streamNameLabel.text = stream.name
        cell.descriptionLabel.text = stream.description
        
        // Update video info when current video changes
		stream.listenForCurrentVideo {[unowned self] error, videoID in
            guard let videoID = videoID else { return }
            // Fetch video info
            self.viewModel.fetchVideo(withID: videoID) {error, video in
                guard let video = video else { return }
                DispatchQueue.main.async {
                    cell.videoTitleLabel.text = video.title
                }
                video.getMediumThumbnail {error, thumbnail in
                    guard let thumbnail = thumbnail else { return }
                    DispatchQueue.main.async {
                        cell.currentVideoThumbnailImageView.image = thumbnail
                    }
                }
			}
		}
		
        // Fetch stream host info
        FacebookDataManager.sharedInstance.fetchInfoForUser(withID: stream.hostFacebookID) {error, user in
            DispatchQueue.main.async {
                cell.hostNameLabel.text = user?.name
            }
            user?.fetchProfileImage {error, image in
                DispatchQueue.main.async {
                    cell.profileImageView.image = image
                }
            }
        }
        
		cell.selectionStyle = .none
		return cell
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
    
    /// Sets the height to be automatic based on constraints.
    ///
    /// - Parameters:
    ///   - tableView: The table requesting the height.
    ///   - indexPath: The index path of the row being requested for.
    /// - Returns: The height of the cell.
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    /// Determine which cells can be selected.
    ///
    /// - Parameters:
    ///   - tableView: The table being selected.
    ///   - indexPath: The index path of the cell that is being selected.
    /// - Returns: The index path that should be selected or nil if none should be.
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return viewModel.shouldSelectCell(at: indexPath) ? indexPath : nil
    }
	
	/// Navigates to the stream associated with the selected cell.
	///
	/// - Parameters:
	///   - tableView: The table that was selected.
	///   - indexPath: The index path of the selected cell.
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Utils.sendGoogleAnalyticsEvent(withCategory: "Home", action: "SelectedStreamInvite")
		let stream = viewModel.streams[indexPath.row]
        guard let streamVC = Utils.instantiateViewController(withIdentifier: "stream", fromStoryboardNamed: "Stream") as? StreamViewController else {
            return
        }
        streamVC.stream = stream
        streamVC.navigationItem.title = stream.name
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(streamVC, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
        }
	}
}
