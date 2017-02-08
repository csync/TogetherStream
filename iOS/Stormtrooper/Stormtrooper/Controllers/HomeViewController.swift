//
//  HomeViewController.swift
//  Stormtrooper
//
//  Created by Nathan Hekman on 11/23/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit
import Foundation
import Crashlytics

class HomeViewController: UIViewController {
	@IBOutlet weak var streamsTableView: UITableView!
	
	fileprivate let viewModel = HomeViewModel()
    
    private let profileButtonFrame = CGRect(x: 0, y: 0, width: 23, height: 23)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupTableView()
        
		viewModel.resetCurrentUserStream()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        displayLoginIfNeeded()
        setupNavigationBar()
        refreshStreams()
        UIView.setAnimationsEnabled(true)
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		viewModel.stopStreamsListening()
	}
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    ///Set bar button items and their actions programmatically
    private func setupNavigationBar() {
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "WorkSans-Regular", size: 17) ?? UIFont.systemFont(ofSize: 17)]
        
        let profileButton = UIButton(type: .custom)
        profileButton.frame = profileButtonFrame
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
        let item1 = UIBarButtonItem(customView: profileButton)
        
        navigationItem.setRightBarButtonItems([item1], animated: false)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    private func setupTableView() {
        streamsTableView.register(UINib(nibName: "StreamTableViewCell", bundle: nil), forCellReuseIdentifier: "streamCell")
        streamsTableView.register(UINib(nibName: "NoStreamsTableViewCell", bundle: nil), forCellReuseIdentifier: "noStreamsCell")
        streamsTableView.contentInset = UIEdgeInsets(top: 9, left: 0, bottom: 0, right: 0)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        streamsTableView.refreshControl = refreshControl
    }
    
    private func displayLoginIfNeeded() {
        if let _ = FacebookDataManager.sharedInstance.profile { //logged in
        }
        else { //if nil, not logged in, show login
            guard let loginVC = Utils.vcWithNameFromStoryboardWithName("login", storyboardName: "Login") as? LoginViewController else {
                return
            }
            present(loginVC, animated: true, completion: { _ in
            })
        }
        logUserWithCrashlytics()
    }
    
    /// Log the current user's id and name with Crashlytics to support detailed crash reports.
    /// (The current user's profile must not be nil.)
    func logUserWithCrashlytics() {
        if let profile = FacebookDataManager.sharedInstance.profile {
            Crashlytics.sharedInstance().setUserIdentifier(profile.userID)
            Crashlytics.sharedInstance().setUserName(profile.name)
        }
    }
    
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
    
    @objc private func refresh(_ refreshControl: UIRefreshControl) {
        refreshStreams() {
            refreshControl.endRefreshing()
        }
    }
    
    @objc private func profileTapped() {
        guard let profileVC = Utils.vcWithNameFromStoryboardWithName("profile", storyboardName: "Profile") as? ProfileViewController else {
            return
        }
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    fileprivate func didSelectInviteFriends() {
        guard let inviteVC = Utils.vcWithNameFromStoryboardWithName("inviteStream", storyboardName: "InviteStream") as? InviteStreamViewController else {
            return
        }
        inviteVC.navigationItem.title = "Invite to Stream"
        navigationController?.pushViewController(inviteVC, animated: true)
    }

    @IBAction func startStreamTapped(_ sender: Any) {
        guard let nameStreamVC = Utils.vcWithNameFromStoryboardWithName("nameStream", storyboardName: "NameStream") as? NameStreamViewController else {
            return
        }
        nameStreamVC.navigationItem.title = "New Stream"
        navigationController?.pushViewController(nameStreamVC, animated: true)
    }

}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfRows
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == viewModel.numberOfRows - 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "noStreamsCell") as? NoStreamsTableViewCell else {
                return UITableViewCell()
            }
            cell.didSelectInviteFriends = {[unowned self] in self.didSelectInviteFriends()}
            cell.selectionStyle = .none
            return cell
        }
        
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "streamCell") as? StreamTableViewCell else {
			return UITableViewCell()
		}
		let stream = viewModel.streams[indexPath.row]
		cell.streamNameLabel.text = stream.name
        cell.descriptionLabel.text = stream.description
		stream.listenForCurrentVideo {[unowned self] error, videoID in
			if let videoID = videoID {
				self.viewModel.getVideo(withID: videoID) {error, video in
					if let video = video {
						DispatchQueue.main.async {
							cell.videoTitleLabel.text = video.title
						}
                        video.getMediumThumbnail {error, thumbnail in
                            if let thumbnail = thumbnail {
                                DispatchQueue.main.async {
                                    cell.currentVideoThumbnailImageView.image = thumbnail
                                }
                            }
                        }
					}
				}
				
			}
		}
		
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return viewModel.shouldSelectCell(at: indexPath) ? indexPath : nil
    }
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let stream = viewModel.streams[indexPath.row]
        guard let streamVC = Utils.vcWithNameFromStoryboardWithName("stream", storyboardName: "Stream") as? StreamViewController else {
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
