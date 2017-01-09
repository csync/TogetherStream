//
//  Message.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 1/9/17.
//  Copyright © 2017 IBM. All rights reserved.
//

protocol Message {
	var subjectID: String { get }
	var timestamp: TimeInterval { get }
	
	init?(content: String)
}
