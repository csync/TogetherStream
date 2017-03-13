//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-ios
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
    /// The default height of the invite cells.
    fileprivate let defaultCellHeight = CGFloat(64.0)
    /// The height of the header cell in the invite table.
    fileprivate let headerCellHeight = CGFloat(47.0)
    /// The frame of the skip invite button.
    private let skipButtonFrame = CGRect(x: 0, y: 0, width: 35, height: 17)
    /// The default message for the text message invitation.
    private let textInviteMessage = "Download Together Stream for iOS - A social and synchronized streaming experience.\nhttp://ibm.biz/together-stream-invite-friends"
    /// The default subject for the email invitation.
    private let emailInviteSubject = "Download Together Stream"
    /// The default body for the email invitation.
    private let emailInviteBody = "Download Together Stream for iOS - A social and synchronized streaming experience.\nhttp://ibm.biz/together-stream-invite-friends"

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
    /// Whether the user should be able to invite other users to the stream.
    var canInviteToStream = false

    override func viewDidLoad() {
        super.viewDidLoad()
        trackScreenView()
        setupNavigationItems()
        setupTableView()

        if isCreatingStream {
            setupViewForCreatingStream()
        }
        if canInviteToStream {
            setupViewForInviteToStream()
        }
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
    
    /// Opens the composer to send a text message invite.
    fileprivate func sendTextInvite() {
        guard MFMessageComposeViewController.canSendText() else {
            showSendMessageErrorAlert()
            return
        }
        
        Utils.sendGoogleAnalyticsEvent(withCategory: "InviteStream", action: "SelectedSendText")
        let messageVC = MFMessageComposeViewController()
        messageVC.messageComposeDelegate = self
        messageVC.body = textInviteMessage
        present(messageVC, animated: true)
    }
    
    fileprivate func sendEmailInvite() {
        guard MFMailComposeViewController.canSendMail() else {
            showSendMailErrorAlert()
            return
        }
        
        Utils.sendGoogleAnalyticsEvent(withCategory: "InviteStream", action: "SelectedSendMail")
        let mailComposerVC = MFMailComposeViewController()
        // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setSubject(emailInviteSubject)
        mailComposerVC.setMessageBody(emailInviteBody, isHTML: false)
        
        present(mailComposerVC, animated: true, completion: nil)
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
    
    /// Sets up the view for when friends can be invited to a stream.
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
    
    /// Shows an alert that email cannot be sent.
    private func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)

        sendMailErrorAlert.addAction(defaultAction)
        present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    /// Shows an alert that text messages cannot be sent.
    private func showSendMessageErrorAlert() {
        let title = "Could Not Send SMS"
        let message = "SMS services are not available on this device."
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}

extension InviteStreamViewController: MFMessageComposeViewControllerDelegate {
    /// On send message finish, dismiss the message compose controller.
    ///
    /// - Parameters:
    ///   - controller: The controller that finished.
    ///   - result: The result of the message composition.
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result) {
        case .cancelled:
            print("Message was cancelled")
            controller.dismiss(animated: true, completion: nil)
        case .failed:
            print("Message failed")
            controller.dismiss(animated: true, completion: nil)
        case .sent:
            print("Message was sent")
            controller.dismiss(animated: true, completion: nil)
        }
    }
    
}

extension InviteStreamViewController: MFMailComposeViewControllerDelegate {
    /// On send email finish, dismiss the email compose controller.
    ///
    /// - Parameters:
    ///   - controller: The controller that finished.
    ///   - result: The result of the email composition.
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch (result) {
        case .cancelled:
            print("Message was cancelled")
            controller.dismiss(animated: true, completion: nil)
        case .failed:
            print("Message failed")
            controller.dismiss(animated: true, completion: nil)
        case .sent:
            print("Message was sent")
            controller.dismiss(animated: true, completion: nil)
        case .saved:
            print("Message was saved")
            controller.dismiss(animated: true, completion: nil)
        }
    }
}

extension InviteStreamViewController: UITableViewDelegate, UITableViewDataSource {
    /// Sends invite or toggles friend selection depending on row seleted.
    ///
    /// - Parameters:
    ///   - tableView: The table that was selected.
    ///   - indexPath: The index path of the selected row.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tableRowsNum = tableView.numberOfRows(inSection: 0)

        switch indexPath.item {
        case 0:
            // Tapped send text
            sendTextInvite()
        case 1:
            // Tapped send email
            sendEmailInvite()
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
            // Show text invite
            guard let textCell = tableView.dequeueReusableCell(withIdentifier: "textEmailCell") as? TextEmailTableViewCell else {
                return UITableViewCell()
            }
            textCell.selectionStyle = .none
            textCell.textEmailLabel.text = "Invite via Text"
            return textCell
        case 1:
            // Show email invite
            guard let emailCell = tableView.dequeueReusableCell(withIdentifier: "textEmailCell") as? TextEmailTableViewCell else {
                return UITableViewCell()
            }
            emailCell.selectionStyle = .none
            emailCell.textEmailLabel.text = "Invite via Email"
            return emailCell
        case 2:
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

    /// Sets the row height based on constants.
    ///
    /// - Parameters:
    ///   - tableView: The table requesting the height.
    ///   - indexPath: The index path of the row the request is for.
    /// - Returns: The height of the cell.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        switch indexPath.item {
        case 2:
            //show header view
            return headerCellHeight
        default:
            return defaultCellHeight
        }
    }

    /// Returns the number of rows for the section based on if user can
    /// invite other users to the stream.
    ///
    /// - Parameters:
    ///   - tableView: The tableview requesting the number.
    ///   - section: The section the request is for.
    /// - Returns: The number of rows for the section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(ifCanInviteToStream: canInviteToStream)
    }
}
