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
import AVKit
import AVFoundation

typealias ResponseCallback = (_ responseData : Any?, _ responseError: ServerError?) -> ()

protocol YoutubeService: class {
    
    func obtainPlaylist(completion: @escaping(ResponseCallback))
    func parseYoutubePlaylist(with playlist: String, completion: @escaping(ResponseCallback))
    func obtainNextVideo(completion: @escaping (ResponseCallback))
    
}

protocol YoutubeServiceOutput {
    func showError(with error: ServerError)
}

class YoutubeServiceImp: YoutubeService {
    
    var serviceOutput: YoutubeServiceOutput?
    var playlistVideoIDs: Array<String> = []
    var playListItemIndex: Int = 0
    var playlistOfAvailableVideos: Array<String> = []
    
    //MARK: - Initialization methods -
    init(with output: YoutubeServiceOutput?) {
        self.serviceOutput = output
    }
    
    //MARK: - Input protocol methods -
    func obtainPlaylist(completion: @escaping (ResponseCallback)) {
        parseYoutubePlaylist(with: Constants.kPlaylistID) { (playlistItems, error) in
            
            if let error = error {
                self.serviceOutput?.showError(with: error)
            } else if let videoItems = playlistItems as? [Item] {
                self.playlistVideoIDs = videoItems.compactMap({$0.contentDetails.videoID})
                self.obtainAllAvailableVideos(with: completion)
            } else {
                completion(nil, ServerError.custom("API works unexpectable"))
            }
        }
    }
    
    func obtainNextVideo(completion: @escaping (ResponseCallback)) {
        
        obtainVideoURL(with: playlistVideoIDs[playListItemIndex], completion: completion)
        
        playListItemIndex += 1
    }
    
    //MARK: - Internal methods -
    
    func parseYoutubePlaylist(with playlist: String, completion: @escaping(ResponseCallback)) {
        
        if !Reachability.isConnectedToNetwork() {
            completion(nil, ServerError.noInternetConnection)
            return
        }
        
        let url = URL(string: "https://www.googleapis.com/youtube/v3/playlistItems")
        Alamofire.request(url!, method: .get, parameters: ["part" : "contentDetails", "maxResults" : 10, "playlistId" : playlist, "key" : Constants.kYoutubeAPIKey], encoding: URLEncoding.default, headers: nil).responseJSON { (response) in

            switch response.result {
            case .success(_):
                let playlist = PlaylistModel.init(data: response.data!)

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
    
    func obtainAllAvailableVideos(with completion: @escaping ResponseCallback) {
        obtainNextVideo { (videoURL, error) in
            if let url = videoURL as? String {
                self.playlistOfAvailableVideos.append(url)
            }
            
            if ( self.playListItemIndex < self.playlistVideoIDs.count ) {
                self.obtainAllAvailableVideos(with: completion)
            } else {
                self.buildVideoPlaylist(with: completion)
            }
        }
    }
    
    func obtainVideoURL(with videoID: String, completion: @escaping ResponseCallback) {
        let youtubeExtractor = YoutubeDirectLinkExtractor()

        youtubeExtractor.extractInfo(for: .id(videoID), success: { info in
            OperationQueue.main.addOperation({
                if let videoLink = info.highestQualityPlayableLink {
                    completion(videoLink, nil)
                } else if let videoLink = info.lowestQualityPlayableLink {
                    completion(videoLink, nil)
                } else {
                    completion(nil, ServerError.custom("Bad video URL"))
                }
            })
        }) { error in
            completion(nil, ServerError.custom(error.localizedDescription))
        }
    }
    
    func buildVideoPlaylist(with completion: @escaping ResponseCallback) {
        
        var videoItem: Array<AVPlayerItem> = []
        
        for videoURL in playlistOfAvailableVideos {
            if let url = URL(string: videoURL) {
                let asset = AVURLAsset(url: url)
                let item = AVPlayerItem(asset: asset)
                videoItem.append(item)
            }
        }
        
        if ( videoItem.count > 0 )
        {
            let videoPlaylist = AVQueuePlayer(items: videoItem)
            completion(videoPlaylist, nil)
        } else {
            completion(nil, ServerError.custom("Playlist doesn't contain playable video"))
        }
    }
}
