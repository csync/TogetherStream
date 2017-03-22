//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-ios
//

import Foundation
import UIKit

class Video {

    let id: String
    let title: String
    let mediumThumbnailURL: URL
    let defaultThumbnailURL: URL
    let channelTitle: String
    let viewCount: String
    let duration: Duration
    
    private var mediumThumbnail: UIImage?
    private var defaultThumbnail: UIImage?
    
    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    init?(jsonObject: [String: Any]) {
        // Check to make sure the video can be played in app
        guard isEmbeddable(jsonObject), !isBlocked(jsonObject) else {
            return nil
        }
        let snippetInfo = jsonObject["snippet"] as? [String: Any]
        let thumbnailsInfo = snippetInfo?["thumbnails"] as? [String: [String : Any]]
        let statisticsInfo = jsonObject["statistics"] as? [String: String]
        guard let id = jsonObject["id"] as? String,
            let title = (snippetInfo?["localized"] as? [String: String])?["title"],
            let mediumThumbnailURLString = thumbnailsInfo?["medium"]?["url"] as? String,
            let defaultThumbnailURLString = thumbnailsInfo?["default"]?["url"] as? String,
            let channelTitle = snippetInfo?["channelTitle"] as? String,
            let mediumThumbnailURL = URL(string: mediumThumbnailURLString),
            let defaultThumbnailURL = URL(string: defaultThumbnailURLString),
            let viewCount = statisticsInfo?["viewCount"],
            let durationString = (jsonObject["contentDetails"] as? [String: Any])?["duration"] as? String,
            let duration = durationString.duration else {
            return nil
        }
        
        self.id = id
        self.title = title
        self.mediumThumbnailURL = mediumThumbnailURL
        self.defaultThumbnailURL = defaultThumbnailURL
        self.channelTitle = channelTitle
        self.duration = duration
        
        if let viewCountInt = Int(viewCount) {
            self.viewCount = Video.numberFormatter.string(from: NSNumber(value: viewCountInt))  ?? ""
        } else {
            self.viewCount = viewCount
        }
    }
    
    func getMediumThumbnail(callback: @escaping (Error?, UIImage?) -> Void) {
        if mediumThumbnail != nil {
            callback(nil, mediumThumbnail)
        }
        else {
            getThumbnailForVideo(with: mediumThumbnailURL) {[weak self] error, image in
                self?.mediumThumbnail = image
                callback(error, image)
            }
        }
    }
    
    func getDefaultThumbnail(callback: @escaping (Error?, UIImage?) -> Void) {
        if defaultThumbnail != nil {
            callback(nil, defaultThumbnail)
        }
        else {
            getThumbnailForVideo(with: defaultThumbnailURL) {[weak self] error, image in
                self?.defaultThumbnail = image
                callback(error, image)
            }
        }
    }
    
    private func getThumbnailForVideo(with url: URL, callback: @escaping (Error?, UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) {data, response, error in
            guard let data = data, let image = UIImage(data: data) else {
                callback(ServerError.unexpectedResponse, nil)
                return
            }
            callback(nil, image)
        }
        task.resume()
    }
}

extension Video: Hashable {
    static func ==(lhs: Video, rhs: Video) -> Bool {
        return lhs.id == rhs.id
    }
    
    var hashValue: Int { return id.hashValue }
}


// Note: these functions are outside the class so they can be called
// before all stored properties are initialized
fileprivate func isEmbeddable(_ videoData: [String: Any]) -> Bool {
    return (videoData["status"] as? [String: Any])?["embeddable"] as? Bool ?? false
}

fileprivate func isBlocked(_ videoData: [String: Any]) -> Bool {
    guard let region = Locale.current.regionCode,
        let blockedRegions = ((videoData["contentDetails"] as? [String: Any])?["regionRestriction"] as? [String: [String]])?["blocked"] else {
            return false
    }
    return blockedRegions.first(where: {$0 == region}) != nil
}
