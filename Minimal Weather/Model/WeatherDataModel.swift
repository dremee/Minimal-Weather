//
//  WeatherDataModel.swift
//  Minimal Weather
//
//  Created by Кирилл Лежнин on 8/22/19.
//  Copyright © 2019 Кирилл Лежнин. All rights reserved.
//

import Foundation

struct WeatherDataModel: Codable {
    //MARK: - Properties
    var city: String
    var main: TempDataModel
    
    enum Keys: String, CodingKey {
        case city = "name"
        case main = "main"
    }
    
    init(from decoder: Decoder) throws {
        let valueContainer = try decoder.container(keyedBy: Keys.self)
        self.city = try valueContainer.decode(String.self, forKey: Keys.city)
        self.main = try valueContainer.decode(TempDataModel.self, forKey: Keys.main)
    }
    
    
}

struct TempDataModel: Codable {
    var temp: Double
    var celsius: Int {
        return Int(self.temp - 273.3)
    }
}


