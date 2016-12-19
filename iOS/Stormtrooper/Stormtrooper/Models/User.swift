//
//  User.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 12/7/16.
//  Copyright © 2016 IBM. All rights reserved.
//

struct User {
	let id: String
	let name: String
	let pictureURL: String
	
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
}
