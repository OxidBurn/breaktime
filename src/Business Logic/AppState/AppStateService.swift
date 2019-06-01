//
//  AppStateService.swift
//  BreakTime
//
//  Created by Nikolay Chaban on 6/1/19.
//  Copyright © 2019 Nikolay Chaban. All rights reserved.
//

import Foundation

protocol AppStateService: class {}

protocol AppStateServiceOutput {
    func didEnterToBackground()
}

class AppStateServiceImp: AppStateService {
    
    //MARK: - Properties -
    var output: AppStateServiceOutput?
    
    //MARK: - Initialization -
    init(with out: AppStateServiceOutput) {
        output = out
        defaultSetup()
    }
    
    //MARK: - Internal methods -
    func defaultSetup() {
        NotificationCenter.default.addObserver(self, selector: #selector(appEnteredToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc func appEnteredToBackground() {
        output?.didEnterToBackground()
    }
    
    //MARK: - Memory management -
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
}
