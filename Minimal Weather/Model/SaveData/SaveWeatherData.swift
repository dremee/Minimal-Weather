//
//  SaveWeatherData.swift
//  Minimal Weather
//
//  Created by Кирилл Лежнин on 8/28/19.
//  Copyright © 2019 Кирилл Лежнин. All rights reserved.
//

import Foundation

final class SaveWeatherData {
    // Get directory path
    private func documentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    // Get file path
    private func dataFilePath() -> URL {
        return documentDirectory().appendingPathComponent("WeatherList.plist")
    }
    
    // Save data
    func saveWeatherListCities(list cityWeatherList: [WeatherDataModel]) {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(cityWeatherList)
            try data.write(to: dataFilePath(), options: .atomic)
        } catch  {
            print("Error encoding cities array: \(error.localizedDescription)")
        }
    }
    
    // Load data
    func loadWheatherListCities() -> [WeatherDataModel]? {
        let path = dataFilePath()
        print(path)
        let cityWeatherList: [WeatherDataModel]
        if let data = try? Data(contentsOf: path) {
            let decoder = PropertyListDecoder()
            do {
                cityWeatherList = try decoder.decode([WeatherDataModel].self, from: data)
                return cityWeatherList
            } catch {
                print("Error decoding city list: \(error.localizedDescription)")
                return nil
            }
        }
        return nil
    }
}
