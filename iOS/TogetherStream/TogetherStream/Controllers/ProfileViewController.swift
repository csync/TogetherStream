//
//  ProfileViewController.swift
//  Stormtrooper
//
//  Created by Nathan Hekman on 11/23/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit
import FBSDKLoginKit

/// View controller for the "Profile" screen.
class ProfileViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var versionLabel: UILabel!
    
    // MARK: - Properties
    
    /// Shorthand for shared FacebookDataManager.
    private let facebookDataManager = FacebookDataManager.sharedInstance
    
    // MARK: - Table Rows
    
    /// The rows that should be displayed on the profile screen.
    fileprivate lazy var rows: [ProfileRow] = {
        /// The row linking to the "Invite" screen.
        let invite = ProfileRow(
            label: "Invite Friends to Together Stream",
            showDisclosure: true,
            action: {[unowned self] in
                Utils.sendGoogleAnalyticsEvent(withCategory: "Profile", action: "SelectedInvite")
                self.pushViewController("inviteStream", from: "InviteStream") {viewController in
                    guard let viewController = viewController as? InviteStreamViewController else {
                        return
                    }
                    viewController.isCreatingStream = false
                    viewController.canInviteToStream = false
                    viewController.navigationItem.title = "Invite to App"
                }
            }
        )
        /// The row linking to the "About" screen.
        let about = ProfileRow(
            label: "About Together Stream",
            showDisclosure: true,
            action: {[unowned self] in
                Utils.sendGoogleAnalyticsEvent(withCategory: "Profile", action: "SelectedAbout")
                self.pushViewController("about")
            }
        )
        /// The row linking to an external feedback page.
        let feedback = ProfileRow(
            label: "Feedback",
            showDisclosure: false,
            action: {[unowned self] in
                Utils.sendGoogleAnalyticsEvent(withCategory: "Profile", action: "SelectedFeedback")
                self.open(url: "https://ibm.biz/together-stream-feedback")
            }
        )
        /// The row which signs out the current user and links back to the "Home" screen.
        let signOut = ProfileRow(
            label: "Sign Out of Facebook",
            showDisclosure: false,
            action: {[unowned self] in
                Utils.sendGoogleAnalyticsEvent(withCategory: "Profile", action: "SelectedSignOut")
                self.facebookDataManager.logOut()
                // Delete server cookie
                if let cookies = HTTPCookieStorage.shared.cookies {
                    for cookie in cookies {
                        print(cookie.domain)
                        if AccountDataManager.sharedInstance.serverAddress.contains(cookie.domain) {
                            HTTPCookieStorage.shared.deleteCookie(cookie)
                            break
                        }
                    }
                }
                // Unauthenticates from CSync
                CSyncDataManager.sharedInstance.unauthenticate {error in
                    DispatchQueue.main.async {
                        guard error == nil else {
                            let alert = UIAlertController(title: "Error Logging out",
                                                          message: error!.localizedDescription,
                                                          preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alert, animated: true)
                            return
                        }
                        
                        _ = self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        )
        return [invite, about, feedback, signOut]
    }()
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trackScreenView()
        setupNavigationItems()
        setupProfilePicture()
        setupNameLabel()
        setupTableView()
        setupVersionNumber()
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        if parent == nil {
            Utils.sendGoogleAnalyticsEvent(withCategory: "Profile", action: "SelectedBackButton")
        }
    }
    
    // MARK: - Helper Functions
    
    /// Set the navigation items for this view controller.
    private func setupNavigationItems() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    /// Set the profile image view using the current user's Facebook profile picture.
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
    
    /// Set the name label with the current user's Facebook profile name.
    private func setupNameLabel() {
        nameLabel.text = facebookDataManager.profile?.name ?? ""
    }
    
    /// Set the version number label.
    private func setupVersionNumber() {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "0.0.0"
        let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) ?? "0"
        let label = "Version \(version) (\(build))"
        versionLabel.text = label
    }
    
    /// Register the nib containing the cell with the table view.
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
    
    /// Push the view controller with the given identifier onto the stack.
    ///
    /// - Parameters:
    ///   - identifier: The identifier of the view controller.
    ///   - storyboard: The identifier of the storyboard.
    ///   - configure: Optional callback to configure the view controller.
    private func pushViewController(_ identifier: String, from storyboard: String = "Profile", withConfiguration configure: ((UIViewController) -> Void)? = nil) {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: identifier)
        configure?(viewController)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    /// Open the given URL in a Safari view controller
    ///
    /// - Parameter url: The URL string to open.
    private func open(url: String) {
        guard let url = URL(string: url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {

    // MARK: - UITableViewDataSource
    
    /// Returns the number of rows for the section.
    ///
    /// - Parameters:
    ///   - tableView: The tableview requesting the number.
    ///   - section: The section the request is for.
    /// - Returns: The number of rows for the section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    /// Dequeues and configures the cell for the given path.
    ///
    /// - Parameters:
    ///   - tableView: The table requesting the cell.
    ///   - indexPath: The path of the cell.
    /// - Returns: The cell to display.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell")
        guard let profileCell = cell as? ProfileTableViewCell else { return UITableViewCell() }
        let row = rows[indexPath.row]
        profileCell.labelText = row.label
        profileCell.accessoryType = (row.showDisclosure) ? .disclosureIndicator : .none
        return profileCell
    }
    
    // MARK: - UITableViewDelegate
    
    /// Performs the action of the selected cell.
    ///
    /// - Parameters:
    ///   - tableView: The table that was selected.
    ///   - indexPath: The path of the cell that was selected.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = rows[indexPath.row]
        row.action()
    }
}

/// Data associated with a profile row.
private struct ProfileRow {
    /// The display label of the cell.
    let label: String
    /// Whether to show the disclosure indicator.
    let showDisclosure: Bool
    /// The action to perform on cell selection.
    let action: (Void) -> Void
}
