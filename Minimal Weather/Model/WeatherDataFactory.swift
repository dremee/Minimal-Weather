//
//  WeatherDataFactory.swift
//  Minimal Weather
//
//  Created by Кирилл Лежнин on 9/11/19.
//  Copyright © 2019 Кирилл Лежнин. All rights reserved.
//

import Foundation

class WeatherDataFactory {
    static func viewModel(for weatherData: WeatherDataModel) -> WeatherDataViewModel {
        return WeatherDataViewModel(city: weatherData.name, tempreture: "\(weatherData.main.celsius)", time: Formatter.changeDateForLocationTime(for: weatherData.timezone))
    }
}
