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

class ViewController: UIViewController{
    
    @IBOutlet weak var videoPlayer: VideoPlayerView!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var tryBtn: UIButton!
    
    private lazy var youtubeService: YoutubeService = {
        let service = YoutubeServiceImp(with: self as YoutubeServiceOutput)
        return service
    }()

    //MARK: - Lifecycle method -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadVideoFromPlaylist()
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            videoPlayer.player?.pause()
            playBtn.isHidden = false
        }
    }
    
    
    //MARK: - Actions -
    
    @IBAction func didClickPlay(_ sender: UIButton) {
        sender.isHidden = true
        videoPlayer.player?.play()
    }
    
    @IBAction func didClickTryAgain(_ sender: UIButton) {
        tryBtn.isHidden = true
        loadVideoFromPlaylist()
    }
    
    
    //MARK: - Internal methods -
    func loadVideoFromPlaylist() {
        SVProgressHUD.show(withStatus: "Loading playlist...")
        
        youtubeService.obtainFirstVideoURL { (videoURL, error) in
            
            if let err = error {
                self.showError(with: err)
            } else if let videoLink = videoURL as? String {
                
                self.startPlay(with: videoLink)
                
            } else {
                self.showError(with: ServerError.custom("Bad video link"))
            }
            
            SVProgressHUD.dismiss()
        }
    }
    
    func startPlay(with link: String) {
        guard let linkURL = URL(string: link) else { return }
        
        let player = AVPlayer(url: linkURL)
        videoPlayer.player = player
        playBtn.isHidden = false
    }
}

extension ViewController: YoutubeServiceOutput, ErrorPresentable {
    //MARK: - Youtube service outout methods -
    func showError(with error: ServerError) {
        
        tryBtn.bringSubviewToFront(videoPlayer)
        tryBtn.isHidden = false
        
        present(error)
    }
}
