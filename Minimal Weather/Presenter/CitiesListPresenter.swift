//
//  Presenter.swift
//  Minimal Weather
//
//  Created by Кирилл Лежнин on 9/27/19.
//  Copyright © 2019 Кирилл Лежнин. All rights reserved.
//

import Foundation

class CitiesListPresenter {
    private var dataManager: DataManagerService!

    public init() {
        dataManager = DataManagerService()
    }
    
    // Make weather data model in ModelView classes
    func returnWeatherViewModelList() -> [WeatherDataViewModel] {
        return dataManager.returnWeatherList().map {WeatherDataFactory.viewModel(for: $0)}
    }
    
    func returnDetailViewModel() -> [DetailWeatherDataViewModel] {
        return dataManager.returnWeatherList().map {WeatherDataFactory.detailViewModel(for: $0)}
    }
    
    //Update data
    func updateData(success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        dataManager.updateData(success: {
            success()
        }) { error in
            failure(error)
        }
    }
    
    //Add data
    func addData(with findCity: String, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        dataManager.addData(with: findCity, success: {
            success()
        }) { error in
            failure(error)
        }
    }
    
    // Delete city from data
    func deleteData(at row: Int) {
        dataManager.deleteData(at: row)
    }
}


