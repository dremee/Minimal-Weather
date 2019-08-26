//
//  WeatherDataModel.swift
//  Minimal Weather
//
//  Created by Кирилл Лежнин on 8/22/19.
//  Copyright © 2019 Кирилл Лежнин. All rights reserved.
//

import Foundation

struct WeatherDataModel: Codable {
    
    let weather: [Weather]
    let main: Main
    let name: String
    let timezone: Int
}


// MARK: - Main
struct Main: Codable {
    let temp: Double
    var celsius: Int {
        return Int(self.temp - 273.3)
    }

    
    enum CodingKeys: String, CodingKey {
        case temp
    }
}

// MARK: - Weather
struct Weather: Codable {
    let id: Int
    let main, weatherDescription, icon: String
    
    enum CodingKeys: String, CodingKey {
        case id, main
        case weatherDescription = "description"
        case icon
    }
}




