//
//  ViewController.swift
//  Minimal Weather
//
//  Created by Кирилл Лежнин on 8/22/19.
//  Copyright © 2019 Кирилл Лежнин. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    //MARK: - Properties
    fileprivate var locationManager = CLLocationManager()
    fileprivate var latitude: String = ""
    fileprivate var longitude: String = ""
    
    //MARK: - Outlets
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    //MAKR: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        initLocationManager()
    }
    
    //MARK: - Actions
    
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
            let weatherURL = URL(string: "https://api.openweathermap.org/data/2.5/weather")
            let url = weatherURL?.withQueries(query)
            let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
                let jsonDecoder = JSONDecoder()
                guard let data = data, let weatherInfo = try? jsonDecoder.decode(WeatherDataModel.self, from: data) else {
                    print("Error with decoding")
                    return
                }
                DispatchQueue.main.async {
                    self.activityIndicatorView.stopAnimating()
                    self.activityIndicatorView.isHidden = true
                    self.cityLabel.text = weatherInfo.city
                    self.tempLabel.text = String(weatherInfo.main.celsius)
                }
            }
            task.resume()
        }
    }
    
    //MARK: - Helpers
    fileprivate func updateUI() {
        activityIndicatorView.startAnimating()
        tempLabel.text = ""
        cityLabel.text = ""
    }
}

