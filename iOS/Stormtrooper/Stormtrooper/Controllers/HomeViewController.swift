//
//  HomeViewController.swift
//  Stormtrooper
//
//  Created by Nathan Hekman on 11/23/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit
import Foundation

class HomeViewController: UIViewController {
	@IBOutlet weak var streamsTableView: UITableView!
	
	fileprivate let viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupBarButtonItems()
		viewModel.resetCurrentUserStream()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        displayLoginIfNeeded()
		viewModel.refreshStreams { error, streams in
			self.streamsTableView.reloadData()
		}
        
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
    private func setupBarButtonItems() {
        let profileButton = UIButton(type: .custom)
        profileButton.setImage(UIImage(named: "stormtrooper_helmet"), for: .normal)
        profileButton.frame = CGRect(x: 0, y: 0, width: 17, height: 19)
        profileButton.addTarget(self, action: #selector(HomeViewController.profileTapped), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: profileButton)
        
        DispatchQueue.main.async {
            self.navigationItem.setRightBarButtonItems([item1], animated: false)
        }
    }
    
    private func displayLoginIfNeeded() {
        if let _ = FacebookDataManager.sharedInstance.profile { //logged in
        }
        else { //if nil, not logged in, show login
            guard let loginVC = Utils.vcWithNameFromStoryboardWithName("login", storyboardName: "Login") as? LoginViewController else {
                return
            }
            DispatchQueue.main.async {
                self.present(loginVC, animated: true, completion: { _ in
                })
            }
        }
    }
    
    func profileTapped() {
        guard let profileVC = Utils.vcWithNameFromStoryboardWithName("profile", storyboardName: "Profile") as? ProfileViewController else {
            return
        }
        DispatchQueue.main.async {
            self.present(profileVC, animated: true, completion: { _ in
            
            })
        }
    }

    @IBAction func startStreamTapped(_ sender: Any) {
        guard let nameStreamVC = Utils.vcWithNameFromStoryboardWithName("nameStream", storyboardName: "NameStream") as? NameStreamViewController else {
            return
        }
        DispatchQueue.main.async {
            nameStreamVC.navigationItem.title = "New Stream"
            self.navigationController?.pushViewController(nameStreamVC, animated: true)
        }
    }

}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.streams.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "streamCell") as? StreamTableViewCell else {
			return UITableViewCell()
		}
		let stream = viewModel.streams[indexPath.row]
		cell.streamNameLabel.text = stream.name
		stream.listenForCurrentVideo {[unowned self] error, videoID in
			if let videoID = videoID {
				self.viewModel.getVideo(withID: videoID) {error, video in
					if let video = video {
						DispatchQueue.main.async {
							cell.videoTitleLabel.text = video.title
						}
					}
				}
				self.viewModel.getThumbnailForVideo(withID: videoID) {error, thumbnail in
					if let thumbnail = thumbnail {
						DispatchQueue.main.async {
							cell.currentVideoThumbnailImageView.image = thumbnail
						}
					}
				}
			}
		}
		
		stream.getFacebookID() {error, facebookID in
			guard let facebookID = facebookID else {
				return
			}
			FacebookDataManager.sharedInstance.fetchInfoForUser(withID: facebookID) {error, user in
				DispatchQueue.main.async {
					cell.hostNameLabel.text = user?.name
				}
				user?.fetchProfileImage {error, image in
					DispatchQueue.main.async {
						cell.profileImageView.image = image
					}
				}
			}
		}
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let stream = viewModel.streams[indexPath.row]
		stream.getFacebookID() {error, facebookID in
			guard let streamVC = Utils.vcWithNameFromStoryboardWithName("stream", storyboardName: "Stream") as? StreamViewController else {
				return
			}
			streamVC.hostID = facebookID
			streamVC.navigationItem.title = stream.name
			DispatchQueue.main.async {
				self.navigationController?.pushViewController(streamVC, animated: true)
				tableView.deselectRow(at: indexPath, animated: true)
			}
		}
		
	}
}
