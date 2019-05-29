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
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var tryBtn: UIButton!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var maxTimerValueLabel: UILabel!
    @IBOutlet weak var minTimerValueLabel: UILabel!
    
    var timeValue: Double = 5
    let volumeView = MPVolumeView()
    var videoTimer: Timer?
    var playlistEnded: Bool = false
    var countOfItems: Int = 0
    var currentItem: Int = 0
    
    
    private lazy var youtubeService: YoutubeService = {
        let service = YoutubeServiceImp(with: self as YoutubeServiceOutput)
        return service
    }()

    //MARK: - Lifecycle method -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.videoPlayer.output = self
        loadVideoFromPlaylist()
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            videoPlayer.player?.pause()
            updateVisibleStateOfCompoments(with: false)
            
            if playlistEnded {
                videoPlayer.alpha = 1.0
                videoPlayer.player?.volume = 1.0
            }
        }
    }
    
    
    //MARK: - Actions -
    
    @IBAction func didClickPlay(_ sender: UIButton) {
        updateVisibleStateOfCompoments(with: true)
        videoPlayer.player?.play()
        self.playlistEnded = false
        videoTimer = Timer.scheduledTimer(withTimeInterval: timeValue*60, repeats: false, block: { timer in
            timer.invalidate()
            self.playlistEnded = true
            self.stopPlayingVideo()
        })
    }
    
    @IBAction func didClickTryAgain(_ sender: UIButton) {
        tryBtn.isHidden = true
        loadVideoFromPlaylist()
    }
    
    @IBAction func updateTimeDuration(_ sender: UISlider) {
        timeLabel.text = String(format: "%.f min", sender.value)
        timeValue = Double(sender.value)
    }
    
    
    //MARK: - Internal methods -
    func loadVideoFromPlaylist() {
        SVProgressHUD.show(withStatus: "Loading playlist...")
        
        youtubeService.obtainPlaylist { (player, error) in
            SVProgressHUD.dismiss()
            guard let p = player else { self.showError(with: error!); return }
            OperationQueue.main.addOperation({
                self.startPlay(with: p as! AVQueuePlayer)
            })
        }
    }
    
    func startPlay(with player: AVQueuePlayer) {
        countOfItems = player.items().count
        videoPlayer.player = player
        updateVisibleStateOfCompoments(with: false)
    }
    
    func updateVisibleStateOfCompoments(with state: Bool) {
        playBtn.isHidden            = state
        timeSlider.isHidden         = state
        timeLabel.isHidden          = state
        maxTimerValueLabel.isHidden = state
        minTimerValueLabel.isHidden = state
    }
    
    func stopPlayingVideo() {
        videoTimer?.invalidate()
        videoPlayer.player?.pause()
        UIView.animate(withDuration: 1.0) {
            self.videoPlayer.alpha = 0.0
            self.videoPlayer.player?.volume = 0.0
            self.videoPlayer.player?.seek(to: CMTime.zero)
            self.updateVisibleStateOfCompoments(with: false)
        }
    }
}

extension ViewController: YoutubeServiceOutput, ErrorPresentable {
    //MARK: - Youtube service outout methods -
    func showError(with error: ServerError) {
        tryBtn.isHidden = false
        present(error)
        SVProgressHUD.dismiss()
    }
}

extension ViewController: VideoPlayerViewOutput {
    func videoPlayDidFinished() {
        currentItem += 1
        
        if currentItem == countOfItems {
            stopPlayingVideo()
        }
    }
}
