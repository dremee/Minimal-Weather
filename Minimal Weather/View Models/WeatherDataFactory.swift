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
    
    
    static func detailViewModel(for weatherData: WeatherDataModel) -> DetailWeatherDataViewModel {
        let detailWeatherInfo = DetailWeatherInfoDataViewModel(temp: String(weatherData.main.celsius), minTemp: String(weatherData.main.minCelsius), maxTemp: String(weatherData.main.maxCelsius), windSpeed: String(weatherData.wind.windSpeed), windDegree: String(weatherData.wind.windDegree ?? 0.0))
        return DetailWeatherDataViewModel(city: weatherData.name, icon: weatherData.weather[0].icon, time: Formatter.changeDateForLocationTimeZone(for: weatherData.timezone), detailWeatherInfoDataViewModel: detailWeatherInfo)
    }
}
