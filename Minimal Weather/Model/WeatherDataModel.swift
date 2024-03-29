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
        return "Weather data model is: \(self.coord), \(self.weather), \(self.main), \(self.name), \(self.timezone), isLocationSearch: \(String(describing: self.isLocationSearch)), wind: \(self.wind)"
    }
    
    var coord: Coord
    var weather: [Weather]
    var main: Main
    var name: String
    var timezone: Int
    var wind: Wind
    // trigger, when searching by location.
    var isLocationSearch: Bool! = false
    
    enum CodingKeys: String, CodingKey {
        case coord, weather, main, name, timezone, isLocationSearch, wind
    }

}


// MARK: - Main
struct Main: Codable {
    let temp: Double
    let tempMin: Double
    let tempMax: Double
    let celsius: Int
    let minCelsius: Int
    let maxCelsius: Int
    
    enum CodingKeys: String, CodingKey {
        case temp
        case tempMin = "temp_min"
        case tempMax = "temp_max"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.temp = try container.decode(Double.self, forKey: CodingKeys.temp)
        self.tempMin = try container.decode(Double.self, forKey: CodingKeys.tempMin)
        self.tempMax = try container.decode(Double.self, forKey: CodingKeys.tempMax)
        
        self.celsius = Int(self.temp - 273.3)
        self.minCelsius = Int(self.tempMin - 273.3)
        self.maxCelsius = Int(self.tempMax - 273.3)
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

struct Wind: Codable {
    let windSpeed: Double
    let windDegree: Double?
    
    
    enum CodingKeys: String, CodingKey {
        case windSpeed = "speed"
        case windDegree = "deg"
    }
}

extension Double {
    var windDegreeRepresentation: String? {
        let degree = Int(self)
        switch degree {
        case 0, 360:
            return "N"
        case 45:
            return "NE"
        case 1..<45:
            return "NNE"
        case 46..<90:
            return "ENE"
        case 90:
            return "E"
        case 91..<135:
            return "ESE"
        case 135:
            return "SE"
        case 136..<180:
            return "SSE"
        case 180:
            return "S"
        case 181..<225:
            return "SSW"
        case 225:
            return "SW"
        case 226..<270:
            return "WSW"
        case 270:
            return "W"
        case 271..<315:
            return "WNW"
        case 315:
            return "NW"
        case 316..<360:
            return "NWN"
        default:
            return nil
        }
    }
}

