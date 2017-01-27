//
//  ServerError.swift
//  Stormtrooper
//
//  Created by Daniel Firsht on 12/9/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation

enum ServerError: Error {
	case cannotFormURL, unexpectedResponse, invalidConfiguration, unexpectedQueueFail
}
