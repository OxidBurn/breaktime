//
//  ViewController.swift
//  BreakTime
//
//  Created by Nikolay Chaban on 5/8/19.
//  Copyright © 2019 Nikolay Chaban. All rights reserved.
//

import UIKit
import SVProgressHUD
import AVFoundation
import MediaPlayer
import AVKit

class ViewController: UIViewController{
    
    @IBOutlet weak var videoPlayer: VideoPlayerView!
    @IBOutlet weak var timerView: TimerView!
    @IBOutlet weak var playerControls: VideoPlayerControls!
    
    var videoTimer: Timer?
    var playlistEnded: Bool = true
    var playerIsHidden: Bool = false
    var countOfItems: Int = 0
    var currentItem: Int = 0
    lazy var appState: AppStateService = {
        let aS = AppStateServiceImp(with: self)
        return aS
    }()
    
    
    private lazy var youtubeService: YoutubeService = {
        let service = YoutubeServiceImp(with: self as YoutubeServiceOutput)
        return service
    }()

    //MARK: - Lifecycle method -
    override func loadView() {
        super.loadView()
        
        videoPlayer.output    = self
        timerView.output      = self
        playerControls.output = self
        
        loadVideoFromPlaylist()
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            videoPlayer.player?.pause()
            videoTimer?.invalidate()
            playerControls.pausePlayTimer()
            updateVisibleStateOfCompoments()
            
            if playlistEnded {
                videoPlayer.alpha = 1.0
                videoPlayer.player?.volume = 1.0
            }
        }
    }
    
    //MARK: - Internal methods -
    func loadVideoFromPlaylist() {
        SVProgressHUD.show(withStatus: "Loading playlist...")
        
        youtubeService.obtainPlaylist { (player, error) in
            SVProgressHUD.dismiss()
            guard let p = player else { self.showError(with: error!); return }
            OperationQueue.main.addOperation({
                self.initializePlay(with: p as! AVQueuePlayer)
            })
        }
    }
    
    func initializePlay(with player: AVQueuePlayer) {
        countOfItems = player.items().count
        videoPlayer.player = player
        updateVisibleStateOfCompoments()
    }
    
    func startTimer(with timeValue: Double) {
        videoTimer = Timer.scheduledTimer(withTimeInterval: timeValue, repeats: false, block: { timer in
            timer.invalidate()
            self.playlistEnded = true
            self.displayCountdownTimer()
        })
    }
    
    func updateVisibleStateOfCompoments() {

        if let status = videoPlayer.player?.timeControlStatus {
            switch status {
            case .paused:
                if playlistEnded {
                    playerControls.display(with: .defaultState)
                } else {
                    playerControls.display(with: .playingState)
                }
                playerControls.isHidden = false
            case .playing, .waitingToPlayAtSpecifiedRate:
                playerControls.isHidden = true
            default:
                print("Default video player status")
            }
        }
    }
    
    func stopPlayingVideo() {
        videoTimer?.invalidate()
        fadeVideoVolume()
        UIView.animate(withDuration: 10.0,
                       animations: {
                        self.videoPlayer.alpha = 0.0
        }) { (finished) in
            self.videoPlayer.player?.pause()
            self.videoPlayer.player?.seek(to: CMTime.zero)
            self.playerIsHidden = true
            self.updateVisibleStateOfCompoments()
        }
    }
    
    func displayCountdownTimer() {
        timerView.isHidden = false
        timerView.startTimer()
    }
    
    func resetPlayerViewState() {
        videoPlayer.alpha = 1.0
        videoPlayer.player?.volume = 1.0
        playerIsHidden = false
    }
    
    func fadeVideoVolume(){
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {[weak self] (timer) in
            self?.videoPlayer.player?.volume -= 0.1
            
            if self?.videoPlayer.player?.volume == 0.0 {
                timer.invalidate()
            }
        }
    }
}

extension ViewController: YoutubeServiceOutput, ErrorPresentable {
    //MARK: - Youtube service outout methods -
    func showError(with error: ServerError) {
        present(error)
        SVProgressHUD.dismiss()
    }
}

extension ViewController: VideoPlayerViewOutput {
    func videoPlayDidFinished() {
        currentItem += 1
        
        if currentItem == countOfItems {
            displayCountdownTimer()
        }
    }
}

extension ViewController: TimerViewOutput {
    func didFinishedTimer() {
        timerView.isHidden = true
        stopPlayingVideo()
    }
}

extension ViewController: AppStateServiceOutput {
    func didEnterToBackground() {
        videoPlayer.player?.pause()
        playerControls.pausePlayTimer()
        updateVisibleStateOfCompoments()
    }
}

extension ViewController: VideoPlayerControlsOutput {
    func didStartPlayer(with timeDelay: Double) {
        if playerIsHidden {
            resetPlayerViewState()
        }
        videoPlayer.player?.play()
        playlistEnded = false
        startTimer(with: timeDelay)
        updateVisibleStateOfCompoments()
    }
    
    func didResumePlayer(with leftTime: Double) {
        startTimer(with: leftTime)
        videoPlayer.player?.play()
        updateVisibleStateOfCompoments()
    }
    
    func didResetPlayer() {
        videoTimer?.invalidate()
        videoPlayer.player?.pause()
        videoPlayer.player?.seek(to: CMTime.zero)
        updateVisibleStateOfCompoments()
    }
}
