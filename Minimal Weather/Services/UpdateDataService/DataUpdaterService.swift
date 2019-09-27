//
//  DataUpdater.swift
//  Minimal Weather
//
//  Created by Кирилл Лежнин on 9/13/19.
//  Copyright © 2019 Кирилл Лежнин. All rights reserved.
//

import Foundation

//protocol DataUpdaterProtocol {
////    var cityWeatherList: [WeatherDataModel] {get}
//    func loadData(success: @escaping () -> ())
//    func updateData(success: @escaping () -> (), failure: @escaping (Error) -> ())
//    func addData(with city: String, success: @escaping () -> (), failure: @escaping (Error) -> ())
//    func deleteData(at index: Int)
//}

//MARK: - Class, that manipulating data for presenters
class DataUpdaterService {
    private let locationService = LocationService.shared
    private let weatherInfoController = NetworkController()
//    private let fileManager = FileManagerController()
    private var cityWeatherList = [WeatherDataModel]()
    
    
    init() {
        self.locationService.delegate = self
        loadData()
    }
    
    
    func returnWeatherList() -> [WeatherDataModel] {
        return cityWeatherList
    }
    
    
    private func loadData() {
        guard let data = FileManager.load(filePath: filePath) else {return}
        cityWeatherList = data.model(with: [WeatherDataModel].self) ?? []
    }
    
    func updateData(success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        updateLocationRow()
        for (index, weatherData) in cityWeatherList.enumerated() {
            var query = [String: String]()
            // here we need to update all data. But, we need undeestand, what we need update all rows, include location row.
            query = queryHelper(index: index,
                                weatherData: weatherData)
            
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
                
                guard let data = self.cityWeatherList.data else {return}
                FileManager.save(data: data, filePath: self.filePath)
                success()
            }, failure: { error in
                failure(error)
            })
        }
    }
    
    //MARK: - Helper for update data
    
    
    func addData(with city: String, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        let query = ["q": city, "appid": "6ba713b340e3501610cdeb5793382e29"]
        self.weatherInfoController.fetchWeatherRequestController(query: query,
                                                                 success: { (weatherInfo) in
                                                                    self.cityWeatherList.append(weatherInfo)
                                                                    guard let data = self.cityWeatherList.data else {return}
                                                                    FileManager.save(data: data, filePath: self.filePath)
                                                                    success()
        }, failure: {error in
            failure(error)
        })
    }
    
    fileprivate func updateLocationRow(query: [String: String]) {
        weatherInfoController.fetchWeatherRequestController(query: query,
                                                            success: { (weatherInfo) in
                                                                var currentWeather = weatherInfo
                                                                currentWeather.isLocationSearch! = true
                                                                if self.cityWeatherList.isEmpty{
                                                                    self.cityWeatherList.append(currentWeather)
                                                                    
                                                                } else if !self.cityWeatherList.isEmpty && self.cityWeatherList[0].isLocationSearch {
                                                                    self.cityWeatherList[0] = currentWeather
                                                                    
                                                                } else {
                                                                    self.cityWeatherList.insert(currentWeather, at: 0)
                                                                    
                                                                }
                                                                guard let data = self.cityWeatherList.data else {return}
                                                                FileManager.save(data: data, filePath: self.filePath)
        }, failure: { error in
            
        })
    }
    
    func deleteData(at index: Int) {
        self.cityWeatherList.remove(at: index)
        guard let data = self.cityWeatherList.data else {return}
        FileManager.save(data: data, filePath: self.filePath)
    }
    
    private func updateLocationRow() {
        locationService.checkLocationStatus()
        if !cityWeatherList.isEmpty && locationService.locationAuthStatus == .denied && cityWeatherList[0].isLocationSearch {
            cityWeatherList.remove(at: 0)
            guard let data = self.cityWeatherList.data else {return}
            FileManager.save(data: data, filePath: self.filePath)
        }
    }
}

//MARK: - Helper query for update data
extension DataUpdaterService {
    fileprivate func queryHelper(index: Int, weatherData: WeatherDataModel) -> [String: String] {
        // in first, we check, that it is 0 row, location search and we have latitude and longitude. If app just running, we don't update this row
        var query = [String: String]()
        if index == 0 &&
            weatherData.isLocationSearch &&
            locationService.locationAuthStatus == .alllow &&
            locationService.latitude != nil &&
            locationService.longitude != nil {
            query = ["lat": locationService.latitude!,
                     "lon": locationService.longitude!,
                     "appid": "6ba713b340e3501610cdeb5793382e29"]
        } else if index == 0 &&
            weatherData.isLocationSearch {
            //here we check, that location manager is denied. I think, i will delete firs row here
            return query
        } else {
            // in all another situations, we just update with city
            query = ["q": weatherData.name, "appid": "6ba713b340e3501610cdeb5793382e29"]
        }
        return query
    }
}

//MARK: - Location service delegate
extension DataUpdaterService: LocationServiceDelegate {
    func locationManagerGetLocation(latitude: String, longitude: String) {
        print("Location service from DataUpdater: lat: \(latitude), lon: \(longitude)")
        let query = ["lat": latitude,
                     "lon": longitude,
                     "appid": "6ba713b340e3501610cdeb5793382e29"]
        updateLocationRow(query: query)
    }
}


extension DataUpdaterService {
    var filePath: URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return path.appendingPathComponent("WeatherList.plist")
    }
}
