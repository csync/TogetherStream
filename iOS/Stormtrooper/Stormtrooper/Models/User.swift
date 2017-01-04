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
	}
	
	func fetchProfileImage(callback: @escaping (Error?, UIImage?) -> Void) {
		if profileImage != nil {
			callback(nil, profileImage)
		}
		guard let url = URL(string: pictureURL) else {
			callback(ServerError.cannotFormURL, nil)
			return
		}
		let task = URLSession.shared.dataTask(with: url) {data, response, error in
			if let data = data, let profileImage = UIImage(data: data) {
				self.profileImage = profileImage
				callback(nil, profileImage)
			}
			else {
				callback(error, nil)
			}
		}
		
		task.resume()
	}
}
