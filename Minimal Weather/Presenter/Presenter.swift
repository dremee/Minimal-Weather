//
//  Presenter.swift
//  Minimal Weather
//
//  Created by Кирилл Лежнин on 9/27/19.
//  Copyright © 2019 Кирилл Лежнин. All rights reserved.
//

import Foundation

class Presenter {
    
    private var dataService = DataUpdaterService.shared
    
    func loadCityList(success: @escaping () -> ()) {
        dataService.loadData {
            success()
        }
    }
    
    func returnWeatherViewModelList() -> [WeatherDataViewModel] {
        return dataService.returnWeatherList().map {WeatherDataFactory.viewModel(for: $0)}
    }
    
    func returnDetailViewModel() -> [DetailWeatherDataViewModel] {
        return dataService.returnWeatherList().map {WeatherDataFactory.detailViewModel(for: $0)}
    }
}
