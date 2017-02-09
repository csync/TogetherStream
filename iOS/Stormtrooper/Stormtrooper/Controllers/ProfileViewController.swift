//
//  ProfileViewController.swift
//  Stormtrooper
//
//  Created by Nathan Hekman on 11/23/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var versionLabel: UILabel!
    
    // MARK: - Properties
    
    private let facebookDataManager = FacebookDataManager.sharedInstance
    
    // MARK: - Table Rows
    
    private lazy var rows: [ProfileRow] = {
        let invite = ProfileRow(
            label: "Invite Friends to Together Stream",
            showDisclosure: true,
            action: { self.pushViewController("inviteStream", from: "InviteStream")
            {viewController in
                guard let viewController = viewController as? InviteStreamViewController else {
                    return
                }
                viewController.isCreatingStream = false
                viewController.canInviteToStream = false
                viewController.navigationItem.title = "Invite to App"
            }
        }
        )
        let about = ProfileRow(
            label: "About Together Stream",
            showDisclosure: true,
            action: { self.pushViewController("about") }
        )
        let disclaimer = ProfileRow(
            label: "Disclaimer",
            showDisclosure: true,
            action: { self.pushViewController("disclaimer") }
        )
        let privacy = ProfileRow(
            label: "Privacy Policy",
            showDisclosure: false,
            action: { self.open(url: "https://ibm.biz/together-stream-privacy-policy") }
        )
        let licenses = ProfileRow(
            label: "Licenses",
            showDisclosure: false,
            action: { self.open(url: "https://ibm.biz/together-stream-licenses") }
        )
        let signOut = ProfileRow(
            label: "Sign Out of Facebook",
            showDisclosure: false,
            action: {
                self.facebookDataManager.logOut()
                _ = self.navigationController?.popViewController(animated: true)
            }
        )
        return [invite, about, disclaimer, privacy, licenses, signOut]
    }()
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupProfilePicture()
        setupNameLabel()
        setupTableView()
        setupVersionNumber()
    }
    
    // MARK: - Helper Functions
    
    /// Set the back button's text to the empty string
    private func setupNavigationBar() {
        let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
    }
    
    /// Set the profile image view using the current user's Facebook profile picture
    private func setupProfilePicture() {
        let facebookDataManager = FacebookDataManager.sharedInstance
        facebookDataManager.fetchProfilePictureForCurrentUser() { error, image in
            if let image = image {
                DispatchQueue.main.async {
                    self.profileImageView.image = image
                }
            }
        }
    }
    
    /// Set the name label with the current user's Facebook profile name
    private func setupNameLabel() {
        nameLabel.text = facebookDataManager.profile?.name ?? ""
    }
    
    /// Set the version number label
    private func setupVersionNumber() {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "0.0.0"
        let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) ?? "0"
        let label = "Version \(version) (\(build))"
        versionLabel.text = label
    }
    
    /// Register the nib containing the cell with the table view
    private func setupTableView() {
        let nib = UINib(nibName: "ProfileTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "profileCell")
        
        // add separator above first cell
        let width = tableView.frame.size.width
        let height = 1 / UIScreen.main.scale // 1 pixel
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        let line = UIView(frame: frame)
        line.backgroundColor = tableView.separatorColor
        tableView.tableHeaderView = line
        
        // add a zero-height footer to hide trailing empty cells
        tableView.tableFooterView = UIView()
    }
    
    /// Push the view controller with the given identifier onto the stack
    private func pushViewController(_ identifier: String, from storyboard: String = "Profile", withConfiguration configure: ((UIViewController) -> Void)? = nil) {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: identifier)
        configure?(viewController)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    /// Open the given URL in a Safari view controller
    private func open(url: String) {
        guard let url = URL(string: url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell")
        guard let profileCell = cell as? ProfileTableViewCell else { return UITableViewCell() }
        let row = rows[indexPath.row]
        profileCell.labelText = row.label
        profileCell.accessoryType = (row.showDisclosure) ? .disclosureIndicator : .none
        return profileCell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = rows[indexPath.row]
        row.action()
    }
}

/// Data associated with a profile row
private struct ProfileRow {
    let label: String
    let showDisclosure: Bool
    let action: (Void) -> Void
}
