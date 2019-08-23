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
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var logoImageView: UIImageView!
    //MAKR: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        initLocationManager()
    }
    
    //MARK: - Actions
    

    
    //MARK: - Helpers
    fileprivate func updateUI() {
        activityIndicatorView.startAnimating()
        tempLabel.text = ""
        cityLabel.text = ""
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
                    self.cityLabel.text = weatherInfo.name
                    self.tempLabel.text = "\(weatherInfo.main.celsius) ℃"
                    let imageURL = URL(string: "https://openweathermap.org/img/wn/\(weatherInfo.weather[0].icon)@2x.png")
                    guard let url = imageURL, let imageData = try? Data(contentsOf: url) else {return}
                    self.logoImageView.image = UIImage(data: imageData)
                    print(weatherInfo.weather[0].icon)
                }
            }
        }
    }
    
}
