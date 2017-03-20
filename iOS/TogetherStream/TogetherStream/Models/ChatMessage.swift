//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-ios
//

import Foundation

struct ChatMessage: Message {
    let subjectID: String
    let timestamp: TimeInterval
    
    let content: String
    
    let csyncPath: String
    
    init?(content: String, csyncPath: String) {
        guard let data = content.data(using: .utf8) else {
            return nil
        }
        do {
            guard let messageJson = try JSONSerialization.jsonObject(with: data) as? [String: String], let id = messageJson["id"], let content = messageJson["content"], let timestamp = TimeInterval(messageJson["timestamp"] ?? "") else {
                return nil
            }
            self.subjectID = id
            self.content = content
            self.timestamp = timestamp
            self.csyncPath = csyncPath
        }
        catch {
            return nil
        }
    }
}
