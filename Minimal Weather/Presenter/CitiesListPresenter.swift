//
//  Presenter.swift
//  Minimal Weather
//
//  Created by Кирилл Лежнин on 9/27/19.
//  Copyright © 2019 Кирилл Лежнин. All rights reserved.
//

import Foundation

class CitiesListPresenter {
    private var dataService = DataUpdaterService.shared
    
    private func loadCityList() {
        dataService.loadData()
    }
    
    public init() {
        loadCityList()
    }
    
    // Make weather data model in ModelView classes
    func returnWeatherViewModelList() -> [WeatherDataViewModel] {
        return dataService.returnWeatherList().map {WeatherDataFactory.viewModel(for: $0)}
    }
    
    func returnDetailViewModel() -> [DetailWeatherDataViewModel] {
        return dataService.returnWeatherList().map {WeatherDataFactory.detailViewModel(for: $0)}
    }
    
    //Update data
    func updateData(success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        dataService.updateData(success: {
            success()
        }) { error in
            failure(error)
        }
    }
    
    //Add data
    func addData(with findCity: String, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        dataService.addData(with: findCity, success: {
            success()
        }) { error in
            failure(error)
        }
    }
    
    // Delete city from data
    func deleteData(at row: Int) {
        dataService.deleteData(at: row)
    }
}


