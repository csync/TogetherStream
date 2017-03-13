//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-ios
//

import Foundation
import CSyncSDK

/// Manages sending and receiving chat messages.
class ChatDataManager {
	/// Closure called when a message is received.
	var didReceiveMessage: ((ChatMessage) -> Void)?
    /// Closure called when a deleted message is received.
    var didReceiveDeletedMessageAtPath: ((String) -> Void)?
    
	/// Shorthand for the CSyncDataManager
	private let csyncDataManager = CSyncDataManager.sharedInstance
	/// The CSync key path of the stream.
	private let streamPath: String
	/// The id of the user sending chat messages.
	private let id: String
	/// The CSync key used to listen for new chat messages.
	private var listenChatKey: Key
	
	/// Creates a new ChatDataManager
	///
	/// - Parameters:
	///   - streamPath: CSync key path of the stream.
	///   - id: The id of the user sending chat messages.
	init(streamPath: String, id: String) {
		self.streamPath = streamPath
		self.id = id
		listenChatKey = csyncDataManager.createKey(atPath: streamPath + ".chat.*")
		setupChatListner()
	}
	
	/// Sends the given message to the stream as the initialized user.
	///
	/// - Parameter message: The message to send.
	func send(message: String) {
		let keyPath = streamPath + ".chat." + UUID().uuidString
        // Encode message
        let message = "{\"id\":\"\(id)\", \"content\":\"\(message)\", \"timestamp\":\"\(Date.timeIntervalSinceReferenceDate)\"}"
		csyncDataManager.write(message, toKeyPath: keyPath, withACL: .PublicReadWrite)
	}
	
	/// Sets up listener of new chat messages.
	private func setupChatListner() {
		listenChatKey.listen {[weak self] value, error in
			if let error = error {
				print(error)
                return
			}
            guard let value = value else {
                    return
            }
            // Check if message is deleted
            if !value.exists {
                self?.didReceiveDeletedMessageAtPath?(value.key)
                return
            }
            // Decodes valid messages
            guard let content = value.data,
                let message = ChatMessage(content: content, csyncPath: value.key) else {
                        return
            }
            self?.didReceiveMessage?(message)
		}
	}
	
	deinit {
		listenChatKey.unlisten()
	}
}
