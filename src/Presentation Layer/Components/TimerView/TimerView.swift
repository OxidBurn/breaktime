//
//  TimerView.swift
//  BreakTime
//
//  Created by Nikolay Chaban on 5/30/19.
//  Copyright © 2019 Nikolay Chaban. All rights reserved.
//

import UIKit

protocol TimerViewOutput: class {
    func didFinishedTimer()
}

class TimerView: UIView {

    @IBOutlet weak var timeLabel: UILabel!
    var output: TimerViewOutput?
    
    //MARK: - Initialization -
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let xibView: UIView = Bundle.main.loadNibNamed("TimerView", owner: self, options: nil)?.first as! UIView
        
        self.addSubview(xibView)
    }
    
    //MARK: - Input methods -
    func startTimer() {
        var timeCount = 10
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            timeCount -= 1
            self.timeLabel.text = "\(timeCount)"
            
            if timeCount == 0 {
                timer.invalidate()
                self.output?.didFinishedTimer()
            }
        }
    }
}
