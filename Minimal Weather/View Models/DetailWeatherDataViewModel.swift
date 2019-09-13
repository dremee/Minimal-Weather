//
//  DetailWeatherDataViewModel.swift
//  Minimal Weather
//
//  Created by Кирилл Лежнин on 9/13/19.
//  Copyright © 2019 Кирилл Лежнин. All rights reserved.
//

import Foundation

struct DetailWeatherDataViewModel {
    let city: String
    let icon: String
    let time: String
    let detailWeatherInfoDataViewModel: DetailWeatherInfoDataViewModel
}

struct DetailWeatherInfoDataViewModel {
    let temp: String
    let minTemp: String
    let maxTemp: String
    let windSpeed: String
    var windDegree: String
}
