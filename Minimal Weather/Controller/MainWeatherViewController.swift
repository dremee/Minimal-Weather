//
//  ViewController.swift
//  Minimal Weather
//
//  Created by Кирилл Лежнин on 8/22/19.
//  Copyright © 2019 Кирилл Лежнин. All rights reserved.
//

import UIKit
import CoreLocation

class MainWeatherViewController: UIViewController {
    //MARK: - Properties
    fileprivate var locationManager = CLLocationManager()
    fileprivate var latitude: String = ""
    fileprivate var longitude: String = ""
    //MARK: - Networking
    fileprivate let weatherInfoController = WeatherInfoController()
    
    //MARK: - Outlets
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var localDateLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var logoImageView: UIImageView!
    
    //MAKR: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWeather()
        initLocationManager()
    }
    
    //MARK: - Actions
    @IBAction func findByCity(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Find by city name", message: "Enter city name to find it's weather", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        let okAction = UIAlertAction(title: "Find", style: .default) { [weak alert] (_) in
            self.loadWeather()
            if let textField = alert?.textFields![0].text!, textField.count > 0 {
                let query = ["q": textField, "appid": "6ba713b340e3501610cdeb5793382e29"]
                self.weatherInfoController.fetchWeatherRequestController(query: query, completion: { (weatherInfo) in
                    if let weatherInfo = weatherInfo {
                        self.updateUI(icon: weatherInfo.weather[0].icon, timezone: weatherInfo.timezone, city: weatherInfo.name, temp: "\(weatherInfo.main.celsius)")
                    } else {
                        DispatchQueue.main.async {
                            self.cityLabel.text = "City not found, try again!"
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

    
    //MARK: - Helpers
    fileprivate func loadWeather() {
        logoImageView.isHidden = true
        tempLabel.text = ""
        cityLabel.text = ""
        localDateLabel.text = ""
        activityIndicatorView.startAnimating()
    }
    
    fileprivate func updateUI(icon: String, timezone: Int, city: String, temp: String) {
        self.activityIndicatorView.stopAnimating()
        self.activityIndicatorView.isHidden = true
        localDateLabel.text = Formatter.changeDateForLocationTimeZone(for: timezone)
        cityLabel.text = city
        tempLabel.text = "\(temp) ℃"
        let imageURL = URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")
        DispatchQueue.global(qos: .background).async {
            guard let url = imageURL, let imageData = try? Data(contentsOf: url) else {return}
            DispatchQueue.main.async {
                self.logoImageView.isHidden = false
                self.logoImageView.image = UIImage(data: imageData)
            }
            
        }
        
    }
}

extension MainWeatherViewController: CLLocationManagerDelegate {
    //MARK: - Location Manager
    func initLocationManager() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    //Location manager delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            latitude = String(location.coordinate.latitude)
            longitude = String(location.coordinate.longitude)
            
            let query = ["lat": latitude, "lon": longitude, "appid": "6ba713b340e3501610cdeb5793382e29"]
            weatherInfoController.fetchWeatherRequestController(query: query) { (weatherInfo) in
                if let weatherInfo = weatherInfo {
                    self.updateUI(icon: weatherInfo.weather[0].icon, timezone: weatherInfo.timezone, city: weatherInfo.name, temp: "\(weatherInfo.main.celsius)")
                }
            }
        }
    }
    
}
