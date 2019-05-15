//
//  PlaylistModel.swift
//  BreakTime
//
//  Created by Nikolay Chaban on 5/14/19.
//  Copyright © 2019 Nikolay Chaban. All rights reserved.
//

import Foundation
import SwiftyJSON

struct PlaylistModel {
    let kind, etag, nextPageToken: String?
    let pageInfo: PageInfo?
    let items: [Item]?
}

struct Item {
    let kind, etag, id: String?
    let contentDetails: ContentDetails?
}

struct ContentDetails {
    let videoID, videoPublishedAt: String?
}

struct PageInfo {
    let totalResults, resultsPerPage: Int?
}

extension PlaylistModel {
    init?(json: Dictionary<String, Any>) {
        
        guard let kind = json["kind"] as? String else { return nil }
        
        self.kind = kind
        self.etag = json["etag"] as? String
        self.nextPageToken = json["nextPageToken"] as? String
        self.pageInfo = PageInfo.init(json: json["pageInfo"] as! Dictionary<String, Any>)
        
        let itemsRaw = json["items"] as? [Dictionary<String, Any>]
        self.items = itemsRaw?.compactMap(Item.init(json:))
    }
}

extension Item {
    init?(json: Dictionary<String, Any>) {
        guard let kind = json["kind"] as? String else { return nil }
        
        self.kind = kind
        self.etag = json["etag"] as? String
        self.id   = json["id"] as? String
        self.contentDetails = ContentDetails.init(json: json["contentDetails"] as! Dictionary<String, Any>)
    }
}

extension ContentDetails {
    init?(json: Dictionary<String, Any>) {
        guard let videoID = json["videoId"] as? String else { return nil }
        
        self.videoID = videoID
        self.videoPublishedAt = json["videoPublishedAt"] as? String
    }
}

extension PageInfo {
    init?(json: Dictionary<String, Any>) {
        guard let totalResults = json["totalResults"] as? Int else { return nil }
        
        self.totalResults = totalResults
        self.resultsPerPage = json["resultsPerPage"] as? Int
    }
}
