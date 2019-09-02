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
    //MARK: - properties
    @IBOutlet weak var tableView: UITableView!
    
    private let locationManager = CLLocationManager()
    private var weatherInfoController = WeatherInfoController()
    private var selectedWeather: WeatherDataModel?
    private var cityWeatherList = [WeatherDataModel]()
    private var latitude: String?
    private var longitude: String?
    private var fileManager = SaveWeatherData()
    
    private var locationAuthStatus = ErrorHandling.LocationAuthStatus.denied
    

    
    //MARK: - View Lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        //create footer bar, for not display empty cells
        tableView.tableFooterView = UIView()
        let cellNib = UINib(nibName: "WeatherViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "WeatherViewCell")
        let errorCellNib = UINib(nibName: "ErrorViewCell", bundle: nil)
        tableView.register(errorCellNib, forCellReuseIdentifier: "ErrorViewCell")
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                locationAuthStatus = .denied
            case .authorizedAlways, .authorizedWhenInUse:
                locationAuthStatus = .alllow
            }
        }
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(updateWeather))
        self.navigationItem.leftBarButtonItem = refreshButton
        
        let addCityButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCity))
        self.navigationItem.rightBarButtonItem = addCityButton
        initLocationManager()
        if let data = fileManager.loadWheatherListCities() {
            cityWeatherList = data
        }
        updateWeather()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateWeather()
    }
    
    //MARK: - Actions
    @objc func addCity() {
            let alert = UIAlertController(title: "Find by city name", message: "Enter city name to find it's weather", preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            let okAction = UIAlertAction(title: "Find", style: .default) { [weak alert] (_) in
                    
                if let textField = alert?.textFields![0].text!, textField.count > 0 {
                    var findCity = textField.trimmingCharacters(in: .whitespaces)
                    findCity = findCity.replacingOccurrences(of: " ", with: "+")
                    let query = ["q": findCity, "appid": "6ba713b340e3501610cdeb5793382e29"]
                    self.weatherInfoController.fetchWeatherRequestController(query: query, completion: { (weatherInfo) in
                        if let weatherInfo = weatherInfo {
                            self.cityWeatherList.append(weatherInfo)
                            self.fileManager.saveWeatherListCities(list: self.cityWeatherList)
                            self.tableView.reloadData()
                        } else {
                            DispatchQueue.main.async {
                                 self.tableView.reloadData()                            }
                        }
                    })
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            present(alert, animated: true)
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetailSegue" {
            if let vc = segue.destination as? DetailWeatherViewController {
                vc.currentWeatherInfo = selectedWeather
            }
        }
    }
    
    //MARK: - Helper
    @objc func updateWeather() {
        for (index, city) in cityWeatherList.enumerated() {
            // update only added cities
            if index != 0 {
                let query: [String: String] = ["q": city.name, "appid": "6ba713b340e3501610cdeb5793382e29"]
                self.weatherInfoController.fetchWeatherRequestController(query: query) { (weatherInfo) in
                    if let weatherInfo = weatherInfo {
                        self.cityWeatherList[index] = weatherInfo
                        self.tableView.reloadData()
                        self.fileManager.saveWeatherListCities(list: self.cityWeatherList)
                    } else {
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                        
                    }
                }
            }
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
    
    //    Header cell
}

//MARK: - Location Manager extension
extension CitiesListViewController: CLLocationManagerDelegate {
    private func initLocationManager() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.startUpdatingLocation()
    }
    
    //Location manager delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            latitude = String(location.coordinate.latitude)
            longitude = String(location.coordinate.longitude)
            let query = ["lat": latitude!, "lon": longitude!, "appid": "6ba713b340e3501610cdeb5793382e29"]
            weatherInfoController.fetchWeatherRequestController(query: query) { (weatherInfo) in
                if var weatherInfo = weatherInfo {
                    // We check, if we already have  current location weather. If it true, we update current location. If list is empty, just append element. If list is not empty, and top city is not found by location, insert our location at 0 index
                    weatherInfo.isLocationSearch! = true
                    if self.cityWeatherList.isEmpty{
                        self.cityWeatherList.append(weatherInfo)
                        self.tableView.reloadData()
                    } else if !self.cityWeatherList.isEmpty && self.cityWeatherList[0].isLocationSearch {
                        self.cityWeatherList[0] = weatherInfo
                        let indexPath = IndexPath(row: 0, section: 0)
                        if let cell = self.tableView.cellForRow(at: indexPath) as? WeatherViewCell {
                            cell.updateCell(for: weatherInfo)
                        }
                        // if list is not empty and top element not found with location
                    } else {
                        self.cityWeatherList.insert(weatherInfo, at: 0)
                        self.tableView.reloadData()
                    }
                    self.fileManager.saveWeatherListCities(list: self.cityWeatherList)
                }
            }
        }
    }
}


