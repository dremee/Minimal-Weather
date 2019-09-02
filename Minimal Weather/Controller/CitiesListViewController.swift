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

class CitiesListViewController: UITableViewController {
    //MARK: - properties
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
        tableView.tableFooterView = UIView()
        let cellNib = UINib(nibName: "WeatherViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "WeatherViewCell")
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
    @IBAction func addCity(_ sender: Any) {
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
                                 self.errorAlert()
                            }
                        }
                    })
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            present(alert, animated: true)
    }
    
    //error alert
    fileprivate func errorAlert() {
        let title: String
        let message: String
        switch ErrorHandling.networkStatus {
        case .DecodingError:
            title = "Error with city"
            message = "Error with adding city information"
        case .NetworkError:
            title = "Network Error"
            message = "Problem with get information. It may be problem with internet connection or server was crash"
        default:
            title = "All good, it's not appear"
            message = "It is not appear"
        }
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(ac, animated: true)
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
                        self.errorAlert()
                    }
                }
            }
        }
        
        
    }
    
    
    //MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityWeatherList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedWeather = cityWeatherList[indexPath.row]
        performSegue(withIdentifier: "ShowDetailSegue", sender: nil)
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let cell = tableView.cellForRow(at: indexPath) as? WeatherViewCell
        cell?.weatherView.backgroundColor = .black
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 && cityWeatherList[0].isLocationSearch {
            return false
        }
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                self.cityWeatherList.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                fileManager.saveWeatherListCities(list: cityWeatherList)
                self.tableView.reloadData()
            }
    }
        
    
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


