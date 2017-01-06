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

    var hasShownLogin = false
	
	fileprivate let viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //show login once for now
        //TODO: save logged in state
        if !hasShownLogin {
            self.displayLoginIfNeeded()
        }
		viewModel.refreshStreams { error, streams in
			self.streamsTableView.reloadData()
		}
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		viewModel.stopStreamsListening()
	}
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func displayLoginIfNeeded() {
        guard let loginVC = Utils.vcWithNameFromStoryboardWithName("login", storyboardName: "Main") as? LoginViewController else {
            return
        }
        self.present(loginVC, animated: true, completion: { _ in
            self.hasShownLogin = true
        })
        
    }
    
    @IBAction func settingsTapped(_ sender: Any) {
        guard let settingsVC = Utils.vcWithNameFromStoryboardWithName("settings", storyboardName: "Main") as? SettingsViewController else {
            return
        }
        self.present(settingsVC, animated: true, completion: { _ in
            
        })
    }

    @IBAction func startStreamTapped(_ sender: Any) {
        guard let nameStreamVC = Utils.vcWithNameFromStoryboardWithName("nameStream", storyboardName: "Main") as? NameStreamViewController else {
            return
        }
        nameStreamVC.navigationItem.title = "New Stream"
        self.navigationController?.pushViewController(nameStreamVC, animated: true)
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
				self.viewModel.getThumbnailForVideo(withID: videoID) {error, thumbnail in
					if let thumbnail = thumbnail {
						DispatchQueue.main.async {
							cell.currentVideoThumbnailImageView.image = thumbnail
						}
					}
				}
			}
		}
		
		AccountDataManager.sharedInstance.getExternalIds(forUserID: stream.hostID) {error, ids in
			guard let ids = ids else {
				return
			}
			FacebookDataManager.sharedInstance.fetchInfoForUser(withID: ids["facebook-token"] ?? "") {error, user in
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
}
