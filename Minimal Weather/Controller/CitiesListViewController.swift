//
//  CitiesListViewController.swift
//  Minimal Weather
//
//  Created by Кирилл Лежнин on 8/26/19.
//  Copyright © 2019 Кирилл Лежнин. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation


class CitiesListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - properties
    private var weatherInfoController = WeatherInfoController()
    private var selectedWeather: WeatherDataModel?
    private var cityWeatherList = [WeatherDataModel]()
    private var fileManager = SaveWeatherData()
    fileprivate var locationService = LocationService.shared

    fileprivate var timer = Timer()
    
    
    //Create refresh control
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(updateWeather), for: .valueChanged)
        refreshControl.tintColor = UIColor(red: 240/255, green: 255/255, blue: 149/255, alpha: 1)
        return refreshControl
    }()
    
    // add error view and setup it
    private let errorView: ErrorView = {
        let view = ErrorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private func setupErrorView() {
        view.addSubview(errorView)
        NSLayoutConstraint.activate([
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            errorView.widthAnchor.constraint(equalTo: view.widthAnchor),
            errorView.heightAnchor.constraint(equalToConstant: 100)
            ])
    }
    
    //MARK: - View Lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        tableView.dataSource = self
        tableView.delegate = self
        //create footer bar, for not display empty cells
        tableView.tableFooterView = UIView()
        tableView.refreshControl = refreshControl
        //add weather custom cell
        let cellNib = UINib(nibName: "WeatherViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "WeatherViewCell")
        
        
        
        //Create add city button and add it like right bar button item
        let addCityButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCity))
        self.navigationItem.rightBarButtonItem = addCityButton
        
        
        //Make safe unwrapping from file manager, and if it exist, update weather
        if let data = fileManager.loadWheatherListCities() {
            cityWeatherList = data
            updateWeather()
        }
        
        setupErrorView()
        
        
        //Reload data every 10 seconds
//        reloadDataInTime(time: 10, repeats: true, callback: updateWeather)
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { (_) in
                self.updateWeather()
            })
        }
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetailSegue" {
            if let vc = segue.destination as? DetailWeatherViewController {
                vc.currentWeatherInfo = selectedWeather
            }
        }
    }
    
    //MARK: - Actions
    @objc private func addCity() {
            let alert = UIAlertController(title: "Find by city name", message: "Enter city name to find it's weather", preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            let okAction = UIAlertAction(title: "Find", style: .default) { [weak alert] (_) in
                    
                if let textField = alert?.textFields![0].text!, textField.count > 0 {
                    var findCity = textField.trimmingCharacters(in: .whitespaces)
                    findCity = findCity.replacingOccurrences(of: " ", with: "+")
                    let query = ["q": findCity, "appid": "6ba713b340e3501610cdeb5793382e29"]
                    self.weatherInfoController.fetchWeatherRequestController(query: query, success: { (weatherInfo) in
                        
                        self.cityWeatherList.append(weatherInfo)
                        self.fileManager.saveWeatherListCities(list: self.cityWeatherList)
                        self.tableView.reloadData()
                        
                    }, failure: {error in
                        self.runErrorAnimation(error: error)
                    })
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            present(alert, animated: true)
    }
    

    
    //MARK: - Helper
    
    //update weather list
    @objc private func updateWeather() {
        //check location status from MainLogicViewController
        locationService.checkLocationStatus()
//        We check, does location is work, and if not, delete location row (if it's was)
        updateLocationRow()
        
//        Check, that list is not empty
        if cityWeatherList.isEmpty {
            self.refreshControl.endRefreshing()
            return
        }
        
        for (index, weatherData) in cityWeatherList.enumerated() {
            // update only added cities
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
                self.runErrorAnimation(error: error)
            })
        }
        self.tableView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    //MARK: - Update Weather Helpers
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
    
    //Delete location row, if location manager is off and location row is exist
    private func updateLocationRow() {
        locationService.checkLocationStatus()
        if !cityWeatherList.isEmpty && locationService.locationAuthStatus == .denied && cityWeatherList[0].isLocationSearch {
            cityWeatherList.remove(at: 0)
            fileManager.saveWeatherListCities(list: cityWeatherList)
            tableView.reloadData()
        }
    }
    
    //Actiovating of error view
    private func runErrorAnimation(error: Error) {
        DispatchQueue.main.async {
            self.errorView.handleErrorAnimation(error: error)
        }
    }
    
    

}

//MARK: - TableView Extension
extension CitiesListViewController: UITableViewDataSource, UITableViewDelegate {
    //MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityWeatherList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherViewCell", for: indexPath) as! WeatherViewCell
        //Change selected view to dark grey
        let selectedView = UIView()
        selectedView.backgroundColor = .darkGray
        cell.selectedBackgroundView = selectedView
        
        let currentView = cityWeatherList[indexPath.row]
        cell.updateCell(for: currentView)
        return cell
    }
    
    //MARK: - Table view delegate
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedWeather = cityWeatherList[indexPath.row]
        performSegue(withIdentifier: "ShowDetailSegue", sender: nil)
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let cell = tableView.cellForRow(at: indexPath) as? WeatherViewCell
        cell?.weatherView.backgroundColor = .black
    }
    
    //If first row get with location, don't access user to delete it
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 && cityWeatherList[0].isLocationSearch {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.cityWeatherList.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            fileManager.saveWeatherListCities(list: cityWeatherList)
            self.tableView.reloadData()
        }
    }
}

//MARK: - Location Manager extension
extension CitiesListViewController: LocationServiceDelegate {
    
    func locationManagerGetLocation(latitude: String, longitude: String) {

        let query = ["lat": latitude, "lon": longitude, "appid": "6ba713b340e3501610cdeb5793382e29"]
        weatherInfoController.fetchWeatherRequestController(query: query, success: { (weatherInfo) in
            // We check, if we already have  current location weather. If it true, we update current location. If list is empty, just append element. If list is not empty, and top city is not found by location, insert our location at 0 index
            var currentWeather = weatherInfo
            currentWeather.isLocationSearch! = true
            if self.cityWeatherList.isEmpty{
                self.cityWeatherList.append(currentWeather)
                self.tableView.reloadData()
            } else if !self.cityWeatherList.isEmpty && self.cityWeatherList[0].isLocationSearch {
                self.cityWeatherList[0] = currentWeather
                let indexPath = IndexPath(row: 0, section: 0)
                if let cell = self.tableView.cellForRow(at: indexPath) as? WeatherViewCell {
                    cell.updateCell(for: weatherInfo)
                }
                // if list is not empty and top element not found with location
            } else {
                self.cityWeatherList.insert(currentWeather, at: 0)
                self.tableView.reloadData()
            }
            self.fileManager.saveWeatherListCities(list: self.cityWeatherList)
        }, failure: { error in
            print(error)
        })
    }
}






