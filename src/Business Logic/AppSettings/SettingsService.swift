//
//  StartService.swift
//  BreakTime
//
//  Created by Nikolay Chaban on 5/9/19.
//  Copyright © 2019 Nikolay Chaban. All rights reserved.
//

import Foundation

protocol SettingsService: class {
    func setupStartupDefaults()
}

class SettingsServiceImp: SettingsService {
    
    //MARK: - Input protocol methods -
    func setupStartupDefaults() {
        googleConfiguration()
    }
    
    //MARK: - Internal methods -
    func googleConfiguration() {
        
    }
}
