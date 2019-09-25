//
//  SaveWeatherData.swift
//  Minimal Weather
//
//  Created by Кирилл Лежнин on 8/28/19.
//  Copyright © 2019 Кирилл Лежнин. All rights reserved.
//

import Foundation

final class FileManagerController {
    
    func save(data: Data, filePath: URL) {
        do {
            try data.write(to: filePath, options: .atomic)
        } catch  {
            print("Error encoding cities array: \(error.localizedDescription)")
        }
    }
    
    func load(filePath: URL) -> Data? {
        if let data = try? Data(contentsOf: filePath) {
            return data
        }
        return nil
    }
}
