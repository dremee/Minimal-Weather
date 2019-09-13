//
//  DataUpdater.swift
//  Minimal Weather
//
//  Created by Кирилл Лежнин on 9/13/19.
//  Copyright © 2019 Кирилл Лежнин. All rights reserved.
//

import Foundation

protocol DataUpdaterProtocol {
    var cityWeatherList: [WeatherDataModel] {get}
    func loadData()
    func updateData()
    func addData(with city: String, success: @escaping () -> (), failure: @escaping (Error) -> ())
    func deleteData(at index: Int)
}

//MARK: - Class, that manipulating data for controllers
class DataUpdater: DataUpdaterProtocol {
    private let locationService = LocationService.shared
    private let weatherInfoController = WeatherInfoController()
    private let fileManager = SaveWeatherData()
    var cityWeatherList = [WeatherDataModel]()
    
    private init() {}
    
    //Make it singleton
    static let shared: DataUpdater = DataUpdater()
    
    func loadData() {
        guard let data = fileManager.loadWheatherListCities() else {return}
        cityWeatherList = data
    }
    
    func updateData() {
        
        for (index, weatherData) in cityWeatherList.enumerated() {
            var query = [String: String]()
            // here we need to update all data. But, we need undeestand, what we need update all rows, include location row.
            
            query = queryHelper(index: index, weatherData: weatherData)
            if query.isEmpty {
                continue
            }
            
            self.weatherInfoController.fetchWeatherRequestController(query: query, success: {(weatherInfo) in
                // here i make flag for first row, that found by location
                if index == 0 && weatherData.isLocationSearch {
                    self.cityWeatherList[index] = weatherInfo
                    self.cityWeatherList[index].isLocationSearch = true
                } else {
                    //default flag is false
                    self.cityWeatherList[index] = weatherInfo
                }
                self.fileManager.saveWeatherListCities(list: self.cityWeatherList)
            }, failure: { error in
                
            })
        }
    }
    
    //MARK: - Helper for update data
    private func queryHelper(index: Int, weatherData: WeatherDataModel) -> [String: String] {
        // in first, we check, that it is 0 row, location search and we have latitude and longitude. If app just running, we don't update this row
        var query = [String: String]()
        if index == 0 && weatherData.isLocationSearch && locationService.locationAuthStatus == .alllow && locationService.latitude != nil && locationService.longitude != nil {
            query = ["lat": locationService.latitude!, "lon": locationService.longitude!, "appid": "6ba713b340e3501610cdeb5793382e29"]
        } else if index == 0 && weatherData.isLocationSearch {
            //here we check, that location manager is denied. I think, i will delete firs row here
            return query
        } else {
            // in all another situations, we just update with city
            query = ["q": weatherData.name, "appid": "6ba713b340e3501610cdeb5793382e29"]
        }
        return query
    }
    
    func addData(with city: String, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        let query = ["q": city, "appid": "6ba713b340e3501610cdeb5793382e29"]
        self.weatherInfoController.fetchWeatherRequestController(query: query, success: { (weatherInfo) in
            self.cityWeatherList.append(weatherInfo)
            self.fileManager.saveWeatherListCities(list: self.cityWeatherList)
            success()
        }, failure: {error in
            failure(error)
        })
    }
    
    func deleteData(at index: Int) {
        self.cityWeatherList.remove(at: index)
        fileManager.saveWeatherListCities(list: self.cityWeatherList)
    }
}