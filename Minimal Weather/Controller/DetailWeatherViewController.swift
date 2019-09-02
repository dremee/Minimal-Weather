//
//  ViewController.swift
//  Minimal Weather
//
//  Created by Кирилл Лежнин on 8/22/19.
//  Copyright © 2019 Кирилл Лежнин. All rights reserved.
//

import UIKit
import CoreLocation

class DetailWeatherViewController: UIViewController {
    //MARK: - Properties
    fileprivate var locationManager = CLLocationManager()
    fileprivate var latitude: String = ""
    fileprivate var longitude: String = ""
    var currentWeatherInfo: WeatherDataModel?
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
        if let currentView = currentWeatherInfo {
            print(currentView)
            title = currentView.name
            updateData()
            updateUI(icon: currentView.weather[0].icon, timezone: currentView.timezone, city: currentView.name, temp: currentView.main.celsius)
        }
    }

    
    //MARK: - Helpers
    fileprivate func loadWeather() {
        logoImageView.isHidden = true
        tempLabel.text = ""
        cityLabel.text = ""
        localDateLabel.text = ""
        activityIndicatorView.startAnimating()
    }
    
    fileprivate func updateUI(icon: String, timezone: Int, city: String, temp: Int) {
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
    
    fileprivate func updateData() {
        guard let weatherInfo = currentWeatherInfo else {return}
        let query: [String: String] = ["q": weatherInfo.name, "appid": "6ba713b340e3501610cdeb5793382e29"]
        self.weatherInfoController.fetchWeatherRequestController(query: query) { (weatherInfo) in
            if let weatherInfo = weatherInfo {
               self.currentWeatherInfo = weatherInfo
            }
        }
    }
}

