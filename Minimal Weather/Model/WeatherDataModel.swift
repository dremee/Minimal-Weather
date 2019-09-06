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

struct Wind: Codable {
    let windSpeed: Double
    let windDegree: Double?
    var windDegreeRepresentation: String? {
        guard let windDegree = self.windDegree else {return "--"}
        let degree = Int(windDegree)
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
            return "N"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case windSpeed = "speed"
        case windDegree = "deg"
    }
}



