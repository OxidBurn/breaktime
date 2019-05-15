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

/// A simple `UIView` subclass that is backed by an `AVPlayerLayer` layer.
class VideoPlayerView: UIView {
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
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}
