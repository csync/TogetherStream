//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-ios
//

import Foundation
import CSyncSDK

/// Manages sending and receiving the messages indicating whether a user has joined or left.
class ParticipantsDataManager {
	/// Closure called when a message is received.
	var didReceiveMessage: ((ParticipantMessage) -> Void)?
	/// Shorthand for the CSyncDataManager
	private let csyncDataManager = CSyncDataManager.sharedInstance
	/// The CSync key path of the stream.
	private let streamPath: String
	/// /// The CSync key used to listen for new chat messages.
	private var listenParticipantsKey: Key
	
	/// Creates a new ParticipantsDataManager
	///
	/// - Parameter streamPath: The CSync key path of the stream.
	init(streamPath: String) {
		self.streamPath = streamPath
		listenParticipantsKey = csyncDataManager.createKey(atPath: streamPath + ".participants.*")
		setupParticipantsListner()
	}
	
	/// Sends a messages that the given participant has joined or left the stream.
	///
	/// - Parameters:
	///   - participantID: The id of the participant.
	///   - isJoining: Whether the participant is joining (true) or leaving (false).
	func send(participantID: String, isJoining: Bool) {
		let sendKey = csyncDataManager.createKey(atPath: streamPath + ".participants." + UUID().uuidString)
		sendKey.write("{\"id\":\"\(participantID)\", \"isJoining\":\"\(isJoining)\", \"timestamp\":\"\(Date.timeIntervalSinceReferenceDate)\"}")
	}
	
	/// Sets up listener of new participant messages.
	private func setupParticipantsListner() {
		listenParticipantsKey.listen {[weak self] value, error in
			if let error = error {
				print(error)
			}
            // Decodes valid messages
            guard value?.exists == true,
                let content = value?.data,
                let message = ParticipantMessage(content: content) else {
                    return
            }
            self?.didReceiveMessage?(message)
		}
	}
	
	deinit {
		listenParticipantsKey.unlisten()
	}
}
