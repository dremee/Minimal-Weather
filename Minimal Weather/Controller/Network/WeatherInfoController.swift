//
//  WeatherInfoController.swift
//  Minimal Weather
//
//  Created by Кирилл Лежнин on 8/23/19.
//  Copyright © 2019 Кирилл Лежнин. All rights reserved.
//

import Foundation

struct WeatherInfoController {
    func fetchWeatherRequestController(query: [String: String], success: @escaping (WeatherDataModel) -> (), failure: @escaping (Error) -> ()) {
        let weatherURL = URL(string: "https://api.openweathermap.org/data/2.5/weather")
        let url = weatherURL?.withQueries(query)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if let _ = error {
                failure(NetworkError.FetchingError)
                return
            }
            let jsonDecoder = JSONDecoder()
            guard let data = data, var weatherInfo = try? jsonDecoder.decode(WeatherDataModel.self, from: data) else {

                failure(NetworkError.DecodingError)
                return
            }
            DispatchQueue.main.async {
                weatherInfo.isLocationSearch = false
                success(weatherInfo)
            }
        }
        task.resume()
    }
}
