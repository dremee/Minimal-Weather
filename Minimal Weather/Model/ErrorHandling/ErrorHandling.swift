//
//  ErrorHandling.swift
//  Minimal Weather
//
//  Created by Кирилл Лежнин on 8/29/19.
//  Copyright © 2019 Кирилл Лежнин. All rights reserved.
//

import Foundation

class ErrorHandling {
    enum LocationAuthStatus {
        case alllow
        case denied
    }
    
    static var networkStatus: NetworkError = .NoError
    enum NetworkError {
        case NetworkError
        case DecodingError
        case NoError
    }
}


