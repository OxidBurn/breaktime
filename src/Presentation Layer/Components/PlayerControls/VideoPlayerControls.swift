//
//  VideoPlayerControls.swift
//  BreakTime
//
//  Created by Nikolay Chaban on 6/1/19.
//  Copyright © 2019 Nikolay Chaban. All rights reserved.
//

import Foundation

enum PlayerControlsState {
    case defaultState
    case playingState
}

protocol VideoPlayerControlsOutput {
    func didStartPlayer(with timeDelay: Double)
    func didResumePlayer(with leftTime: Double)
    func didResetPlayer()
}

class VideoPlayerControls: UIView {
    
    //MARK: - Properties -
    @IBOutlet weak var buttonsStack: UIStackView!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var leftTimeLbl: UILabel!
    @IBOutlet weak var minTimeLbl: UILabel!
    @IBOutlet weak var maxTimeLbl: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var timerValueLbl: UILabel!
    
    var output: VideoPlayerControlsOutput?
    var viewState: PlayerControlsState?
    var leftTimeValue: Double = 0
    var originalTimaValue: Double = 300
    var playTimer: Timer?
    
    //MARK: - Initializations -
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let xibView = Bundle.main.loadNibNamed("VideoPlayerControls", owner: self, options: nil)?.first as! UIView
        xibView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        self.addSubview(xibView)
    }
    
    //MARK: - Public methods -
    func display(with state: PlayerControlsState) {
        
        resetBtn.isHidden      = (state == .defaultState)
        timeSlider.isHidden    = (state == .playingState)
        minTimeLbl.isHidden    = (state == .playingState)
        maxTimeLbl.isHidden    = (state == .playingState)
        timerValueLbl.isHidden = (state == .playingState)
        leftTimeLbl.isHidden   = (state == .defaultState)
        
        viewState = state
    }
    
    func pausePlayTimer() {
        playTimer?.invalidate()
    }
    
    //MARK: - Actions -
    @IBAction func didClickPlay(_ sender: UIButton) {
        if viewState == .defaultState {
            output?.didStartPlayer(with: originalTimaValue)
            leftTimeValue = originalTimaValue
        } else {
            output?.didResumePlayer(with: leftTimeValue)
        }
        
        startPlayingTimer()
    }
    
    @IBAction func didClickReset(_ sender: UIButton) {
        output?.didResetPlayer()
        display(with: .defaultState)
    }
    
    @IBAction func didChangedTime(_ sender: UISlider) {
        timerValueLbl.text = String(format: "%.f min", sender.value)
        originalTimaValue = Double(sender.value * 60)
    }
    
    //MARK: - Internal methods -
    func startPlayingTimer() {
        playTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] (timer) in
            self?.leftTimeValue -= 1
            self?.updateLeftTimeLabel()
        }
    }
    
    func updateLeftTimeLabel() {
        if leftTimeValue.isNaN {
            leftTimeLbl.text = "00:00"
        }
        let min = Int(leftTimeValue / 60)
        let sec = Int(leftTimeValue.truncatingRemainder(dividingBy: 60))
        
        leftTimeLbl.text = String(format: "Left time: %02d:%02d", min, sec)
    }
}
