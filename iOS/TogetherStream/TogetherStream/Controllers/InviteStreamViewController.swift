//
//  InviteStreamViewController.swift
//  Stormtrooper
//
//  Created by Nathan Hekman on 12/7/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit
import MessageUI

/// The view controller for the "Invite" screen.
class InviteStreamViewController: UIViewController {
	
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!

    /// The model for the objects in this view.
    fileprivate let viewModel = InviteStreamViewModel()
    /// The frame of the skip invite button.
    private let skipButtonFrame = CGRect(x: 0, y: 0, width: 35, height: 17)
    /// The default message for sharing the stream code.
    private let shareCodeMessage = "Join my stream on Together Stream – A collaborative and synchronized streaming experience. Enter code: %@. http://togetherstream.csync.io/app?stream_id=%@"

    /// Exposed stream object to be set by other view controllers.
    var stream: Stream? {
        get {
            return viewModel.stream
        }
        set {
            viewModel.stream = newValue
        }
    }
    /// The queue of videos to be played.
    /// - Note: This is not used on this screen but is
    /// held to be passed to the Stream View Controller.
    var videoQueue: [Video]?
    /// Whether a stream is currently being created.
    var isCreatingStream = false

    override func viewDidLoad() {
        super.viewDidLoad()
        trackScreenView()
        setupNavigationItems()
        setupTableView()

        if isCreatingStream {
            setupViewForCreatingStream()
        }
        setupViewForInviteToStream()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.setAnimationsEnabled(true)
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        if parent == nil {
            Utils.sendGoogleAnalyticsEvent(withCategory: "InviteStream", action: "SelectedBackButton")
        }
    }
    
    /// On tapping done, send out the invites and present the next screen.
    ///
    /// - Parameter sender: The button that was tapped.
    @IBAction func doneTapped(_ sender: Any) {
        let label = isCreatingStream ? "StreamBeingCreated" : "StreamAlreadyCreated"
        Utils.sendGoogleAnalyticsEvent(withCategory: "InviteStream", action: "FinishedInvitedFriends", label: label, value: viewModel.selectedFriends.count as NSNumber)
        // Send the invites
        viewModel.sendInvitesToSelectedFriends()
        if isCreatingStream {
            // Transition to the "Stream" screen
            guard let streamVC = Utils.instantiateViewController(withIdentifier: "stream", fromStoryboardNamed: "Stream") as? StreamViewController else {
                return
            }
            // Configure stream view controller
            streamVC.stream = stream
            streamVC.videoQueue = videoQueue
            streamVC.navigationItem.title = stream?.name ?? ""
            streamVC.navigationItem.hidesBackButton = true
            navigationController?.pushViewController(streamVC, animated: true)
        }
        else {
            // not creating stream, so pop
            let _ = navigationController?.popViewController(animated: true)
        }
    }
    
    /// On tapping share code, present an activity view to share the code.
   fileprivate func didSelectShareCode() {
        Utils.sendGoogleAnalyticsEvent(withCategory: "InviteStream", action: "PressedShareCode")
        let appID = viewModel.stream?.hostFacebookID ?? ""
        let shareCodeMessage = String(format: self.shareCodeMessage, appID, appID)
        let activityViewController = UIActivityViewController(activityItems: [shareCodeMessage], applicationActivities: nil)
        DispatchQueue.main.async {
          self.present(activityViewController, animated: true)
        }
    }
    
    /// On tapping the code text field, present an action sheet to copy the code.
    fileprivate func didSelectCodeTextField() {
        Utils.sendGoogleAnalyticsEvent(withCategory: "InviteStream", action: "PressedCodeField")
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let copyAction = UIAlertAction(title: "Copy", style: .default) {[weak self] _ in
            UIPasteboard.general.string = self?.viewModel.stream?.hostFacebookID
        }
        actionSheet.addAction(copyAction)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true)
    }
    
    /// Set the navigation items for this view controller
    private func setupNavigationItems() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    /// Sets up the invite table view.
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TextEmailTableViewCell", bundle: nil), forCellReuseIdentifier: "textEmailCell")
        tableView.register(UINib(nibName: "FriendTableViewCell", bundle: nil), forCellReuseIdentifier: "friendCell")
        tableView.register(UINib(nibName: "InviteFriendsHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "friendsHeaderCell")
        tableView.register(UINib(nibName: "InviteCodeTableViewCell", bundle: nil), forCellReuseIdentifier: "inviteCodeCell")
        
        // add a zero-height footer to hide trailing empty cells
        tableView.tableFooterView = UIView()
    }
    
    /// Sets up the view for when a stream is being created.
    private func setupViewForCreatingStream() {
        // Show skip button when creating a stream
        let skipButton = UIButton(type: .custom)
        skipButton.setTitle("Skip", for: .normal)
        skipButton.frame = skipButtonFrame
        skipButton.addTarget(self, action: #selector(InviteStreamViewController.doneTapped), for: .touchUpInside)
        let skipItem = UIBarButtonItem(customView: skipButton)
        
        navigationItem.setRightBarButtonItems([skipItem], animated: false)
    }
    
    /// Sets up the view for friends to be invited to a stream.
    private func setupViewForInviteToStream() {
        // Fetch friends to invite
        viewModel.fetchFriends(callback:{ (error: Error?) -> Void in
            DispatchQueue.main.async {
                if let error = error {
                    let alert = UIAlertController(title: "Error Loading Friends", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
                self.tableView.reloadData()
            }
        })
    }
}

extension InviteStreamViewController: UITableViewDelegate, UITableViewDataSource {
    /// Toggles friend selection or does nothing depending on row seleted.
    ///
    /// - Parameters:
    ///   - tableView: The table that was selected.
    ///   - indexPath: The index path of the selected row.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tableRowsNum = tableView.numberOfRows(inSection: 0)
        
        switch indexPath.row {
        case viewModel.numberOfStaticCellsBeforeFriends...tableRowsNum:
            // Tapped on friend
            if let friendCell = tableView.cellForRow(at: indexPath) as? FriendTableViewCell {
                friendCell.friendIsSelected = !friendCell.friendIsSelected
                let index = viewModel.userCollectionIndexForCell(at: indexPath)
                let friendData = viewModel.facebookFriends[index]
                if friendCell.friendIsSelected {
                    viewModel.selectedFriends[friendData.id] = friendData
                } else {
                    viewModel.selectedFriends[friendData.id] = nil
                }
                
                doneButton.isHidden = viewModel.selectedFriends.values.count == 0
                bottomLayoutConstraint.constant = doneButton.isHidden ? -doneButton.frame.height : 0
            }
        default:
            // Do nothing
            break
        }
    }

    /// Dequeues and configures the cell for the given path.
    ///
    /// - Parameters:
    ///   - tableView: The table requesting the cell.
    ///   - indexPath: The path of the cell.
    /// - Returns: The cell to display.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let numberOfRows = tableView.numberOfRows(inSection: 0)
        
        switch indexPath.row {
        case 0:
            // Show invite code
            guard let inviteCodeCell = tableView.dequeueReusableCell(withIdentifier: "inviteCodeCell") as? InviteCodeTableViewCell else {
                return UITableViewCell()
            }
            inviteCodeCell.selectionStyle = .none
            inviteCodeCell.inviteCodeTextField.text = viewModel.stream?.hostFacebookID
            inviteCodeCell.didSelectShareCode = {[unowned self] in self.didSelectShareCode()}
            inviteCodeCell.didSelectCodeTextField = {[unowned self] in self.didSelectCodeTextField()}
            return inviteCodeCell
        case 1:
            // Show friends header view
            guard let friendsHeaderCell = tableView.dequeueReusableCell(withIdentifier: "friendsHeaderCell") as? InviteFriendsHeaderTableViewCell else {
                return UITableViewCell()
            }
            friendsHeaderCell.selectionStyle = .none
            // Move seperator out of the screen
            friendsHeaderCell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
            friendsHeaderCell.isHidden = viewModel.facebookFriends.count == 0
            return friendsHeaderCell
        case viewModel.numberOfStaticCellsBeforeFriends...numberOfRows:
            // Show Facebook friend
            guard let friendCell = tableView.dequeueReusableCell(withIdentifier: "friendCell") as? FriendTableViewCell else {
                return UITableViewCell()
            }
            
            let index = viewModel.userCollectionIndexForCell(at: indexPath)
            
            let friendData = viewModel.facebookFriends[index]
            
            friendCell.name.text = friendData.name
            friendData.fetchProfileImage { error, image in
                // Using main thread to set image properly
                DispatchQueue.main.async {
                    friendCell.profilePicture.image = image
                }
            }
            friendCell.friendIsSelected = viewModel.selectedFriends[friendData.id] != nil
            
            friendCell.selectionStyle = .none
            return friendCell
        default:
            return UITableViewCell()
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
    
    /// Sets the height to be automatic based on constraints.
    ///
    /// - Parameters:
    ///   - tableView: The table requesting the height.
    ///   - indexPath: The index path of the row being requested for.
    /// - Returns: The height of the cell.
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    /// Returns the number of rows for the section.
    ///
    /// - Parameters:
    ///   - tableView: The tableview requesting the number.
    ///   - section: The section the request is for.
    /// - Returns: The number of rows for the section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }
}
