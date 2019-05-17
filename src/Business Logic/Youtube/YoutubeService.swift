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
    func obtainNextVideo(completion: @escaping (ResponseCallback)) -> Bool
    
}

protocol YoutubeServiceOutput {
    func showError(with error: ServerError)
}

class YoutubeServiceImp: YoutubeService {
    
    var serviceOutput: YoutubeServiceOutput?
    var playlistVideoIDs: Array<String> = []
    var playListItemIndex: Int = 0
    
    //MARK: - Initialization methods -
    init(with output: YoutubeServiceOutput?) {
        self.serviceOutput = output
    }
    
    //MARK: - Input protocol methods -
    func obtainFirstVideoURL(completion: @escaping (ResponseCallback)) {
        parseYoutubePlaylist(with: Constants.kPlaylistID) { (playlistItems, error) in
            
            if let error = error {
                self.serviceOutput?.showError(with: error)
            } else if let videoItems = playlistItems as? [Item] {
                self.playlistVideoIDs = videoItems.compactMap({$0.contentDetails?.videoID})
                if let videoID = self.playlistVideoIDs.first {
                    self.obtainVideoURL(with: videoID, completion: completion)
                } else {
                    completion(nil, ServerError.custom("Video link is absent"))
                }
            } else {
                completion(nil, ServerError.custom("API works unexpectable"))
            }
        }
    }
    
    func obtainNextVideo(completion: @escaping (ResponseCallback)) -> Bool {
        playListItemIndex += 1
        
        if playListItemIndex < playlistVideoIDs.count {
            obtainVideoURL(with: playlistVideoIDs[playListItemIndex], completion: completion)
            return true
        }
        
        return false
    }
    
    //MARK: - Internal methods -
    
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
                
                if let playlistItems = playlist?.items {
                    completion(playlistItems, nil)
                } else {
                    completion(nil, ServerError.custom("Access Not Configured. YouTube Data API has not been used in project 642554659286 before or it is disabled. Enable it by visiting"))
                }
                
            case .failure(let error):
                let displayError = ServerError.custom(error.localizedDescription)
                completion(nil, displayError)
            }
        }
    }
    
    func obtainVideoURL(with videoID: String, completion: @escaping ResponseCallback) {
        
        let infoURL = NSURL(string:"https://www.youtube.com/get_video_info?video_id=\(videoID)")
        let request = NSMutableURLRequest(url: infoURL! as URL)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                print(error)
            } else if let data = data, let result = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String? {
                // Pattern 1
                // Get streaming map directly
                print(result)
            }
        })
        task.resume()
    }
}
