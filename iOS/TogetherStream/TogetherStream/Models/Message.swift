//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-ios
//

import Foundation

protocol Message {
	var subjectID: String { get }
	var timestamp: TimeInterval { get }
}
