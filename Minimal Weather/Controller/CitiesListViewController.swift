//
//  CitiesListViewController.swift
//  Minimal Weather
//
//  Created by Кирилл Лежнин on 8/26/19.
//  Copyright © 2019 Кирилл Лежнин. All rights reserved.
//

import UIKit
import CoreLocation

class CitiesListViewController: UITableViewController {
    //MARK: - properties
    fileprivate let locationManager = CLLocationManager()
    fileprivate var weatherInfoController = WeatherInfoController()
    fileprivate var currentView: WeatherDataModel?
    
    //MARK: - View Lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initLocationManager()
    }
    
    //MARK: - Navigation
    
    
    //MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell", for: indexPath)
        
        if let currentView = currentView {
            cell.textLabel?.text = currentView.name
            cell.detailTextLabel?.text = "\(currentView.main.celsius) ℃"
        } else {
            cell.textLabel?.text = "--"
            cell.detailTextLabel?.text = "--"
        }
        return cell
    }
    //MARK: - Table view delegate
}

extension CitiesListViewController: CLLocationManagerDelegate {
    
    fileprivate func initLocationManager() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    //Location manager delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let query = ["lat": latitude, "lon": longitude, "appid": "6ba713b340e3501610cdeb5793382e29"]
            weatherInfoController.fetchWeatherRequestController(query: query) { (weatherInfo) in
                if let weatherInfo = weatherInfo {
                    self.currentView = weatherInfo
                    self.tableView.reloadData()
                }
            }
        }
    }
    
}
