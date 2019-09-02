//
//  WeatherDataModel.swift
//  Minimal Weather
//
//  Created by Кирилл Лежнин on 8/22/19.
//  Copyright © 2019 Кирилл Лежнин. All rights reserved.
//

import Foundation



struct WeatherDataModel: Codable, CustomStringConvertible {
    var description: String {
        return "Weather data model is: \(self.coord), \(self.weather), \(self.main), \(self.name), \(self.timezone), isLocationSearch: \(String(describing: self.isLocationSearch))"
    }
    
    var coord: Coord
    var weather: [Weather]
    var main: Main
    var name: String
    var timezone: Int
    // trigger, when searching by location.
    var isLocationSearch: Bool! = false
    
    enum CodingKeys: String, CodingKey {
        case coord, weather, main, name, timezone, isLocationSearch
    }

}


// MARK: - Main
struct Main: Codable {
    let temp: Double
    let tempMin: Double
    let tempMax: Double
    var celsius: Int {
        return Int(self.temp - 273.3)
    }
    var minCelsius: Int {
        return Int(self.tempMin - 273.3)
    }
    var maxCelsius: Int {
        return Int(self.tempMax - 273.3)
    }
    
    enum CodingKeys: String, CodingKey {
        case temp
        case tempMin = "temp_min"
        case tempMax = "temp_max"
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

//MARK: - Coord
struct Coord: Codable {
    let lon: Double
    let lat: Double
}




