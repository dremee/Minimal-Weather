//
//  WeatherDataModel+Data.swift
//  Minimal Weather
//
//  Created by Кирилл Лежнин on 9/24/19.
//  Copyright © 2019 Кирилл Лежнин. All rights reserved.
//

import Foundation

extension Array where Element: Codable {
    var data: Data? {
        return try? JSONEncoder().encode(self)
    }
}

extension Data {
    func model<T: Codable>(with type: T.Type) -> T? {
        return try? JSONDecoder().decode(type, from: self)
    }
}


