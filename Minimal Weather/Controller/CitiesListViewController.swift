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

class CitiesListViewController: MainLogicViewController {
    //MARK: - properties
    @IBOutlet weak var tableView: UITableView!
    
//    private let locationManager = CLLocationManager()
    private var weatherInfoController = WeatherInfoController()
    private var selectedWeather: WeatherDataModel?
    private var cityWeatherList = [WeatherDataModel]()

    private var fileManager = SaveWeatherData()
//    private var locationAuthStatus = ErrorHandling.LocationAuthStatus.denied
    
    
    
    //Create refresh control
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(updateWeather), for: .valueChanged)
        refreshControl.tintColor = UIColor(red: 240/255, green: 255/255, blue: 149/255, alpha: 1)
        return refreshControl
    }()
    // add subview
    let errorView: ErrorView = {
        let view = ErrorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private func setupErrorView() {
        view.addSubview(errorView)
        NSLayoutConstraint.activate([
            errorView.topAnchor.constraint(equalTo: view.topAnchor, constant: (self.navigationController?.navigationBar.frame.size.height)!),
            errorView.widthAnchor.constraint(equalTo: view.widthAnchor),
            errorView.heightAnchor.constraint(equalToConstant: 40)
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
        
        let cellNib = UINib(nibName: "WeatherViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "WeatherViewCell")
        
        checkLocationStatus()
        
//        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(updateWeather))
//        self.navigationItem.leftBarButtonItem = refreshButton
        
        let addCityButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCity))
        self.navigationItem.rightBarButtonItem = addCityButton
        initLocationManager()
        if let data = fileManager.loadWheatherListCities() {
            cityWeatherList = data
        }
        updateWeather()
        setupErrorView()
        
        timeReloadInTime(time: 10, repeats: true, callback: updateWeather)
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
                                if !self.errorView.isAnimationRunning {
                                    self.errorView.triggerAnimation()
                                }
                                self.tableView.reloadData()
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
        //We check, does location is work, and if not, delete location row (if it's was)
        updateLocationRow()
        
        
        for (index, city) in cityWeatherList.enumerated() {
            // update only added cities
            var query = [String: String]()
            // here we need to update all data. But, we need undeestand, what we need update all rows, include location row.
            // in first, we check, that it is 0 row, location search and we have latitude and longitude. If app just running, we don't update this row
            if index == 0 && city.isLocationSearch && locationAuthStatus == .alllow && latitude != nil && longitude != nil {
                query = ["lat": latitude!, "lon": longitude!, "appid": "6ba713b340e3501610cdeb5793382e29"]
            } else if index == 0 && city.isLocationSearch && locationAuthStatus == .denied {
                //here we check, that location manager is denied. I think, i will delete firs row here
                continue
            } else {
                // in all another situations, we just update with city
                query = ["q": city.name, "appid": "6ba713b340e3501610cdeb5793382e29"]
            }
            
            self.weatherInfoController.fetchWeatherRequestController(query: query) { (weatherInfo) in
                if let weatherInfo = weatherInfo {
                    // here i make flag for first row, that found by location
                    if index == 0 && city.isLocationSearch {
                        self.cityWeatherList[index] = weatherInfo
                        self.cityWeatherList[index].isLocationSearch = true
                    } else {
                        self.cityWeatherList[index] = weatherInfo
                    }
//                    self.tableView.reloadData()
                    self.fileManager.saveWeatherListCities(list: self.cityWeatherList)
                } else {
                    DispatchQueue.main.async {
                        if !self.errorView.isAnimationRunning {
                            self.errorView.triggerAnimation()
                        }
                        
                    }
                }
            }
        }
        self.tableView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    private func updateLocationRow() {
        checkLocationStatus()
        if locationAuthStatus == .denied && cityWeatherList[0].isLocationSearch {
            cityWeatherList.remove(at: 0)
            fileManager.saveWeatherListCities(list: cityWeatherList)
            tableView.reloadData()
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
extension CitiesListViewController {
    
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


