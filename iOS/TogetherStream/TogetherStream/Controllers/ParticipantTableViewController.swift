//
//  ParticipantTableViewController.swift
//  TogetherStream
//
//  Created by Daniel Firsht on 3/24/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import UIKit

/// The view controller of the "Participant" screen.
class ParticipantTableViewController: UITableViewController {
    
    @IBOutlet var participantTableView: UITableView!
    
    /// The ids of the participants, on set reload users.
    var participantsId: Set<String> = [] {
        didSet {
            participants = []
            self.loadUsers()
        }
    }
    /// The participants of the stream.
    private var participants: [User] = []
    /// The header heighter
    private let participantTableHeaderViewHeight: CGFloat = 55

    override func viewDidLoad() {
        super.viewDidLoad()
        
        participantTableView.register(UINib(nibName: "ParticipantTableViewCell", bundle: nil), forCellReuseIdentifier: "participantCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    /// Returns the number of rows for the section.
    ///
    /// - Parameters:
    ///   - tableView: The tableview requesting the number.
    ///   - section: The section the request is for.
    /// - Returns: The number of rows for the section.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return participants.count
    }
    
    /// Instantiates and configures the table header.
    ///
    /// - Parameters:
    ///   - tableView: The table requesting the header.
    ///   - section: The section the header is for.
    /// - Returns: The header view.
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView =  ParticipantHeaderView.instanceFromNib()
        headerView.numberParticipantsLabel.text = "\(participants.count) STREAM PARTICIPANT" + (participants.count != 1 ? "S" : "")
        return headerView
    }
    
    /// Sets the height of the header.
    ///
    /// - Parameters:
    ///   - tableView: The table requesting the header height.
    ///   - section: The section the request is for.
    /// - Returns: The height of the header.
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return participantTableHeaderViewHeight
    }
    
    /// Dequeues and configures the cell for the given path.
    ///
    /// - Parameters:
    ///   - tableView: The table requesting the cell.
    ///   - indexPath: The path of the cell.
    /// - Returns: The cell to display.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let participantCell = tableView.dequeueReusableCell(withIdentifier: "participantCell") as? ParticipantTableViewCell else {
            return UITableViewCell()
        }
        let participant = participants[indexPath.row]
        // Set user info
        participantCell.nameLabelView.text = participant.name +
            (participant.id == FacebookDataManager.sharedInstance.profile?.userID ?? "" ? " (you)" : "")
        participant.fetchProfileImage{ error, image in
            guard let image = image else {
                print(error as Any)
                return
            }
            DispatchQueue.main.async {
                participantCell.profileImageView?.image = image
            }
        }
        
        participantCell.selectionStyle = .none
        return participantCell
    }
    
    /// Sets the height to be automatic based on constraints.
    ///
    /// - Parameters:
    ///   - tableView: The table requesting the height.
    ///   - indexPath: The index path of the row being requested for.
    /// - Returns: The height of the cell.
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    /// Sets the height to be automatic based on constraints.
    ///
    /// - Parameters:
    ///   - tableView: The table requesting the height.
    ///   - indexPath: The index path of the row being requested for.
    /// - Returns: The height of the cell.
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    /// Fetch the user info for all participants.
    private func loadUsers() {
        for id in participantsId {
            FacebookDataManager.sharedInstance.fetchInfoForUser(withID: id) {error, user in
                if let user = user {
                    self.insertIntoParticipants(user: user)
                    // Reloads table on insertion
                    if self.participantTableView != nil {
                        DispatchQueue.main.async {
                            self.participantTableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    /// Inserts the given user into the participants array.
    ///
    /// - Parameter user: The user to insert.
    private func insertIntoParticipants(user: User) {
        // The current user should be first
        if user.id == FacebookDataManager.sharedInstance.profile?.userID ?? "" {
            participants.insert(user, at: 0)
            return
        }
        // Otherwise add in some consistant order
        let searchRange = (participants.count > 0 && participants[0].id == FacebookDataManager.sharedInstance.profile?.userID ?? "") ? 1..<participants.count : 0..<participants.count
        if let index = participants[searchRange].index(where: {$0.name > user.name}) {
            participants.insert(user, at: index)
            return
        }
        // If no other users and not the current user, add to the end
        participants.append(user)
    }
}
