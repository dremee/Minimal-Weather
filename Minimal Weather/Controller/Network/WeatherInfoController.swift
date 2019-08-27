//
//  WeatherInfoController.swift
//  Minimal Weather
//
//  Created by Кирилл Лежнин on 8/23/19.
//  Copyright © 2019 Кирилл Лежнин. All rights reserved.
//

import Foundation

struct WeatherInfoController {
    func fetchWeatherRequestController(query: [String: String], completion: @escaping (WeatherDataModel?) -> ()) {
        let weatherURL = URL(string: "https://api.openweathermap.org/data/2.5/weather")
        let url = weatherURL?.withQueries(query)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            guard let data = data, let weatherInfo = try? jsonDecoder.decode(WeatherDataModel.self, from: data) else {
                print("Error with decoding")
                completion(nil)
                return
            }
            DispatchQueue.main.async {
                completion(weatherInfo)
            }
        }
        task.resume()
    }
}