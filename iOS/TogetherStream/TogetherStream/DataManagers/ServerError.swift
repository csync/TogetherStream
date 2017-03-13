//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-ios
//

import Foundation

enum ServerError: Error {
	case cannotFormURL, unexpectedResponse, invalidConfiguration, unexpectedQueueFail, cannotGetDeviceToken
}
