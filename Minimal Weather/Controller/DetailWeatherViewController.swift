//
//  ViewController.swift
//  Minimal Weather
//
//  Created by Кирилл Лежнин on 8/22/19.
//  Copyright © 2019 Кирилл Лежнин. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class DetailWeatherViewController: UIViewController {
    //MARK: - Properties
    fileprivate var locationManager = CLLocationManager()
    fileprivate var latitude: String = ""
    fileprivate var longitude: String = ""
    var currentWeatherInfo: WeatherDataModel?
    var timer = Timer()
    
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
        if let currentView = currentWeatherInfo {
            print(currentView)
            title = currentView.name
            self.updateUI(icon: currentView.weather[0].icon, timezone: currentView.timezone, city: currentView.name, temp: currentView.main.celsius)
            //make timer for auto updating
            if currentView.isLocationSearch {
                self.locationInit()
            }
            DispatchQueue.main.async {
                self.timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { [weak self](_) in
                    print("Updated")
                    if let self = self {
                        self.updateData()
                    }
                    
                })
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //destroy timer
        timer.invalidate()
    }
    
    deinit {
        print("Deinit detail vc")
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
    
    @objc func updateData() {
        print("Reload")
        guard let weatherInfo = currentWeatherInfo else {return}
        self.loadWeather()
        var query = [String: String]()
        if weatherInfo.isLocationSearch && longitude.count > 0 && latitude.count > 0 {
            query = ["lat": latitude, "lon": longitude, "appid": "6ba713b340e3501610cdeb5793382e29"]
        } else if weatherInfo.isLocationSearch {
            self.navigationController?.popViewController(animated: true)
        } else {
            query = ["q": weatherInfo.name, "appid": "6ba713b340e3501610cdeb5793382e29"]
        }
        
        self.weatherInfoController.fetchWeatherRequestController(query: query) { [weak self](weatherInfo) in
            print(query)
            guard let self = self else {return}
            //have to update data, without updating isLocationSearch for control next updating
            if let currentView = weatherInfo {
                self.currentWeatherInfo?.coord = currentView.coord
                self.currentWeatherInfo?.name = currentView.name
                self.currentWeatherInfo?.main = currentView.main
                self.currentWeatherInfo?.weather = currentView.weather
                self.updateUI(icon: currentView.weather[0].icon, timezone: currentView.timezone, city: currentView.name, temp: currentView.main.celsius)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
            
        }
    }
}

extension DetailWeatherViewController: CLLocationManagerDelegate {
    // Initialize loction manager when city was found by geolocation data
    func locationInit() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.startUpdatingLocation()
    }
    
    // just update latitude and longitude
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            latitude = String(location.coordinate.latitude)
            longitude = String(location.coordinate.longitude)
        }
    }
}
