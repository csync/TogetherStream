//
//  User.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 12/7/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation
import UIKit

class User {
	let id: String
	let name: String
	let pictureURL: String
	private var profileImage: UIImage?
    
    private var imageCallbackQueue: ThreadSafeCallbackQueue<UIImage>
    
	/*
	Response format of GraphAPI 2.8
	"name": "<name>",
	"picture": {
		"data": {
			"is_silhouette": <bool>,
			"url": "<url>"
		}
	},
	"id": "<id>"
	*/
	init(facebookResponse: [String: Any]) {
		let picture = (facebookResponse["picture"] as? [String: Any])?["data"] as? [String: Any]
		id =  facebookResponse["id"] as? String ?? ""
		name =  facebookResponse["name"] as? String ?? ""
		pictureURL = picture?["url"] as? String ?? ""
        imageCallbackQueue = ThreadSafeCallbackQueue<UIImage>(identifier: "image.\(id)")
	}
	
	func fetchProfileImage(callback: @escaping (Error?, UIImage?) -> Void) {
		if profileImage != nil {
			callback(nil, profileImage)
            return
		}
        let queueStatus = imageCallbackQueue.addCallbackAndCheckQueueStatus(callback: callback)
        if queueStatus.alreadySucceeded {
            if let profileImage = profileImage {
                callback(nil, profileImage)
            }
            else {
                callback(ServerError.unexpectedQueueFail, profileImage)
            }
        }
        else if queueStatus.didAddFirst {
            guard let url = URL(string: pictureURL) else {
                imageCallbackQueue.executeAndClearCallbacks(withError: ServerError.cannotFormURL, object: nil)
                return
            }
            let task = URLSession.shared.dataTask(with: url) {data, response, error in
                if let data = data, let profileImage = UIImage(data: data) {
                    self.profileImage = profileImage
                    self.imageCallbackQueue.executeAndClearCallbacks(withError: nil, object: profileImage)
                }
                else {
                    self.imageCallbackQueue.executeAndClearCallbacks(withError: error, object: nil)
                }
            }
            
            task.resume()
        }
	}
}
