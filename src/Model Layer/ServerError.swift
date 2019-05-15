//
//  ServerError.swift
//  BitcoinTicker
//
//  Created by Nikolay Chaban on 1/7/19.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import Foundation
import SwiftyJSON

enum ServerError : Error {
    case noInternetConnection
    case custom(String)
    case other
}

extension ServerError : LocalizedError {
    var errorDescription : String? {
        switch self {
        case .noInternetConnection:
            return "No Internet Connection"
        case .other:
            return "Something went wrong"
        case .custom(let message):
            return message
        }
    }
}

extension ServerError {
    
    init?(json : JSON) {
        if let message = json["message"] as? String {
            self = .custom(message)
        } else {
            self = .other
        }
    }
}
