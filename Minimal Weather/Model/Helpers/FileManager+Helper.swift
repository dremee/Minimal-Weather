//
//  SaveWeatherData.swift
//  Minimal Weather
//
//  Created by Кирилл Лежнин on 8/28/19.
//  Copyright © 2019 Кирилл Лежнин. All rights reserved.
//

import Foundation

extension FileManager {
    static func save(data: Data, filePath: URL) {
        try? data.write(to: filePath, options: .atomic)
    }
    
    static func load(filePath: URL) -> Data? {
        return try? Data(contentsOf: filePath)
    }
}
