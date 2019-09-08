//
//  ErrorHandling.swift
//  Minimal Weather
//
//  Created by Кирилл Лежнин on 8/29/19.
//  Copyright © 2019 Кирилл Лежнин. All rights reserved.
//

import Foundation


enum LocationAuthStatus {
    case alllow
    case denied
}
    
    
enum NetworkError: Error {
        case FetchingError
        case DecodingError
    }



