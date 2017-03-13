//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-ios
//


import UIKit
import Foundation

/// View model for the "Invite" screen.
class InviteStreamViewModel {
    /// The stream the invites are for.
    var stream: Stream?

    /// The number of cells before friends are listed.
    let numberOfStaticCellsBeforeFriends = 2
    /// Calculates the number of rows in the invite table.
    var numberOfRows: Int {
        return numberOfStaticCellsBeforeFriends + facebookFriends.count
    }

    /// The friends that are selected, mapped user ID to user.
    var selectedFriends: [String: User] = [:]
    /// The facebook friends of the user that have the app.
    private(set) var facebookFriends:[User] = []
    
    /// Shorthand for the shared AccountDataManager.
    private let accountDataManager = AccountDataManager.sharedInstance
    /// Shorthand for the shared FacebookDataManager.
    private let facebookDataManager = FacebookDataManager.sharedInstance
    
    /// Returns the collection index for the user listed by the row
    /// at the given index path.
    ///
    /// - Parameter indexPath: The index path of the row.
    /// - Returns: The index of the user.
    func userCollectionIndexForCell(at indexPath: IndexPath) -> Int {
        return indexPath.row - numberOfStaticCellsBeforeFriends
    }

    /// Fetches all friends of the logged in user who are also
    /// using the app, removes blocked friends and then updates the model.
    ///
    /// - Parameter callback: The callback called on completion. A nil error
    /// means it was successful.
    func fetchFriends(callback: @escaping (Error?) -> Void) {
        FacebookDataManager.sharedInstance.fetchFriends { error, friends in
            guard var friends = friends, error == nil else {
                callback(error)
                return
            }
            AccountDataManager.sharedInstance.retrieveBlocks { error, userIDs in
                guard let userIDs = userIDs, error == nil else {
                    callback(error)
                    return
                }
                friends = friends.filter {!userIDs.contains($0.id)}
                self.facebookFriends = friends
                callback(nil)
            }
        }
    }

    /// Sends the selected friends an invite to the current stream.
    func sendInvitesToSelectedFriends() {
        let users = [User](selectedFriends.values)
        if let stream = stream, users.count > 0 {
            accountDataManager.sendInvite(for: stream, to: users)
        }
    }
}
