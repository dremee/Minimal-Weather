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
    fileprivate let locationManager = CLLocationManager()
    fileprivate var weatherInfoController = WeatherInfoController()
    fileprivate var selectedWeather: WeatherDataModel?
    fileprivate var locationWeather: WeatherDataModel?
    fileprivate var cityWeatherList = [WeatherDataModel]()
    
    //MARK: - View Lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initLocationManager()
        loadWheatherListCities()
    }
    
    //MARK: - Actions
    @IBAction func addCity(_ sender: Any) {
            let alert = UIAlertController(title: "Find by city name", message: "Enter city name to find it's weather", preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            let okAction = UIAlertAction(title: "Find", style: .default) { [weak alert] (_) in
                    
                if let textField = alert?.textFields![0].text!, textField.count > 0 {
                    var findCity = textField.replacingOccurrences(of: " ", with: "+")
                    findCity = findCity.trimmingCharacters(in: .whitespaces)
                    let query = ["q": findCity, "appid": "6ba713b340e3501610cdeb5793382e29"]
                    self.weatherInfoController.fetchWeatherRequestController(query: query, completion: { (weatherInfo) in
                        if let weatherInfo = weatherInfo {
                            self.cityWeatherList.append(weatherInfo)
                            self.saveWeatherListCities()
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
        let ac = UIAlertController(title: "Incorrect city", message: "Error with adding city information", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(ac, animated: true)
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetailSegue" {
            if let vc = segue.destination as? MainWeatherViewController {
                vc.currentWeatherInfo = selectedWeather
            }
        }
    }
    
    //MARK: - File Manager
    
    func documentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func dataFilePath() -> URL {
        return documentDirectory().appendingPathComponent("WeatherList.plist")
    }
    
    func saveWeatherListCities() {
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(cityWeatherList)
            try data.write(to: dataFilePath(), options: .atomic)
        } catch  {
            print("Error encoding cities array: \(error.localizedDescription)")
        }
    }
    
    func loadWheatherListCities() {
        let path = dataFilePath()
        if let data = try? Data(contentsOf: path) {
            let decoder = PropertyListDecoder()
            do {
                cityWeatherList = try decoder.decode([WeatherDataModel].self, from: data)
            } catch {
                print("Error decoding city list: \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityWeatherList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell", for: indexPath)
        if cityWeatherList.count > 0 {
            let currentView = cityWeatherList[indexPath.row]
            cell.textLabel?.text = currentView.name
            cell.detailTextLabel?.text = "\(currentView.main.celsius) ℃"
        } else {
            cell.textLabel?.text = "--"
            cell.detailTextLabel?.text = "--"
        }
        return cell
    }
    //MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedWeather = cityWeatherList[indexPath.row]
        performSegue(withIdentifier: "ShowDetailSegue", sender: nil)
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        }
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                self.cityWeatherList.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                saveWeatherListCities()
            }
    }
        
    
}

extension CitiesListViewController: CLLocationManagerDelegate {
    
    private func initLocationManager() {
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
                    self.cityWeatherList[0] = weatherInfo
                    self.tableView.reloadData()
                }
            }
        }
    }
    
}

