//
//  InviteStreamViewModel.swift
//  Stormtrooper
//
//  Created by Jaime Guajardo on 1/25/17.
//  Copyright © 2017 IBM. All rights reserved.
//


import UIKit
import Foundation

class InviteStreamViewModel {
    private let accountDataManager = AccountDataManager.sharedInstance
    private let facebookDataManager = FacebookDataManager.sharedInstance

    var facebookFriends:[User] = []

    func fetchFriends(callback: @escaping (Error?) -> Void) {
        facebookFriends = FacebookDataManager.sharedInstance.cachedFriends
        FacebookDataManager.sharedInstance.fetchFriends(callback:{ (error: Error?, friends: [User]?) -> Void in
            if (friends != nil) {
                self.facebookFriends = friends!
            }
            callback(error)
        })
    }

    func populateFriendCell(friendCell:FriendTableViewCell, index:Int) {
        if (index >= 0 && index < facebookFriends.count) {
            let friendData = facebookFriends[index]
            let url = URL(string: friendData.pictureURL)

            friendCell.name.text = friendData.name
            friendCell.associatedUser = friendData

            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!)
                DispatchQueue.main.async {
                    friendCell.profilePicture.image = UIImage(data: data!)
                }
            }
        }
    }

    func sendInvites(stream:Stream?, users:[User]) {
        if (stream != nil && users.count > 0) {
            accountDataManager.sendInviteToStream(withName: stream!.name, andDescription: stream!.description, to: users)
        }
    }
}
