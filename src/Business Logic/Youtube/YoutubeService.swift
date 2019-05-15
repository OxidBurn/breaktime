//
//  YoutubeService.swift
//  BreakTime
//
//  Created by Nikolay Chaban on 5/9/19.
//  Copyright © 2019 Nikolay Chaban. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import YoutubeDirectLinkExtractor

typealias ResponseCallback = (_ responseData : Any?, _ responseError: ServerError?) -> ()

protocol YoutubeService: class {
    
    func obtainFirstVideoURL(completion: @escaping(ResponseCallback))
    func parseYoutubePlaylist(with playlist: String, completion: @escaping(ResponseCallback))
    
}

protocol YoutubeServiceOutput {
    func showError(with error: ServerError)
}

class YoutubeServiceImp: YoutubeService {
    
    var serviceOutput: YoutubeServiceOutput?
    
    //MARK: - Initialization methods -
    init(with output: YoutubeServiceOutput?) {
        self.serviceOutput = output
    }
    
    //MARK: - Input protocol methods -
    func obtainFirstVideoURL(completion: @escaping (ResponseCallback)) {
        parseYoutubePlaylist(with: Constants.kPlaylistID) { (playlistItems, error) in
            
            if let error = error {
                self.serviceOutput?.showError(with: error)
            } else {
                let videoItems: [Item] = playlistItems as! [Item]
                let itemIndex = Int.random(in: 0..<videoItems.count)
                let videoItem = videoItems[itemIndex]
                
                let y = YoutubeDirectLinkExtractor()
                
                y.extractInfo(for: .id((videoItem.contentDetails?.videoID)!), success: { (info) in
                    OperationQueue.main.addOperation({
                        completion(info.highestQualityPlayableLink, nil)
                    })
                }, failure: { error in
                    OperationQueue.main.addOperation({
                        completion(nil, ServerError.custom(error.localizedDescription))
                    })
                })
            }
        }
    }
    
    func parseYoutubePlaylist(with playlist: String, completion: @escaping(ResponseCallback)) {
        
        if !Reachability.isConnectedToNetwork() {
            completion(nil, ServerError.noInternetConnection)
            return
        }
        
        let url = URL(string: "https://www.googleapis.com/youtube/v3/playlistItems")
        Alamofire.request(url!, method: .get, parameters: ["part" : "contentDetails", "playlistId" : Constants.kPlaylistID, "key" : Constants.kYoutubeAPIKey], encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            
            switch response.result {
            case .success(let value):
                let json = JSON(value).rawValue as! Dictionary<String, Any>
                let playlist = PlaylistModel.init(json: json)
                completion(playlist?.items, nil)
            case .failure(let error):
                let displayError = ServerError.custom(error.localizedDescription)
                completion(nil, displayError)
            }
        }
    }
}
