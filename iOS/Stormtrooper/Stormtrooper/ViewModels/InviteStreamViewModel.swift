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
    private(set) var facebookFriends:[User] = []

    let numberOfStaticCellsBeforeFriends = 3

    var selectedFriends: [String: User] = [:]

    func fetchFriends(callback: @escaping (Error?) -> Void) {
        let friendIds = FacebookDataManager.sharedInstance.cachedFriendIds

        facebookFriends = []
        for id in friendIds {
            if let user = facebookDataManager.userCache[id] {
                self.facebookFriends.append(user)
            }
        }
        FacebookDataManager.sharedInstance.fetchFriends(callback:{ (error: Error?, friends: [User]?) -> Void in
            if friends != nil {
                self.facebookFriends = friends!
            }
            callback(error)
        })
    }

    func sendInvites(stream:Stream?, users:[User]) {
        if stream != nil && users.count > 0 {
            accountDataManager.sendInviteToStream(withName: stream!.name, andDescription: stream!.description, to: users)
        }
    }
}
