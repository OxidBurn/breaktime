//
//  VideoPlayerView.swift
//  BreakTime
//
//  Created by Nikolay Chaban on 5/15/19.
//  Copyright © 2019 Nikolay Chaban. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

protocol VideoPlayerViewOutput {
    func videoPlayDidFinished()
}

/// A simple `UIView` subclass that is backed by an `AVPlayerLayer` layer.
class VideoPlayerView: UIView {
    
    //MARK: - Properties -
    var output: VideoPlayerViewOutput?
    
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        
        set {
            playerLayer.player = newValue
        }
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    //MARK: - Initialization -
    
    override func awakeFromNib() {
        // Register for notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: nil) // Add observer
    }
    
    
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    
    // Notification Handling
    @objc func playerItemDidReachEnd(notification: NSNotification) {
        player?.seek(to: CMTime.zero)
        output?.videoPlayDidFinished()
    }
    
    
    // Remove Observer
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
