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
        heapConfiguration()
    }
    
    //MARK: - Internal methods -
    func heapConfiguration() {
        Heap.setAppId(Constants.kHeapDev);
        #if DEBUG
            Heap.enableVisualizer();
        #endif
    }
}
