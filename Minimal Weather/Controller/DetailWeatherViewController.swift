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

//MARK: - Protocol to delegate data
protocol DetailWeatherDelegate {
    func updateWeatherDataInStaticTableView(with data: WeatherDataModel)
}

class DetailWeatherViewController: UIViewController {
    //Delegate
    var delegate: DetailWeatherDelegate?
    //MARK: - Properties
    private var locationService = LocationService.shared
    private var timer = Timer()
    private var fileManager = SaveWeatherData()
    var currentWeatherInfo: WeatherDataModel?
    var weatherList = [WeatherDataModel]()
    var currentWeatherIndex: Int?
    var isLocation: Bool = false
    
    
    //MARK: - Networking
    private let weatherInfoController = WeatherInfoController()
    
    //MARK: - Outlets
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    
    //MAKR: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let currentWeather = currentWeatherInfo {
            title = currentWeather.name
            self.locationService.delegate = self
            if currentWeather.isLocationSearch {
            
            }
            self.updateUI(icon: currentWeather.weather[0].icon, timezone: currentWeather.timezone, city: currentWeather.name)
            
            
            
            delegate?.updateWeatherDataInStaticTableView(with: self.currentWeatherInfo!)
            updateData()
            DispatchQueue.main.async {
                self.timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { (_) in
                    self.updateData()
                })
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //destroy timer
        timer.invalidate()
    }
    
    //create for testing ARC
    deinit {
        print("Deinit detail vc")
    }
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? WeatherInfoTableViewController, segue.identifier == "DetailWeatherSegue" {
            self.delegate = vc
            
        }
    }

    
    //MARK: - Helpers
    private func updateUI(icon: String, timezone: Int, city: String) {
        self.title = city
        self.cityLabel.text = city
        self.currentTimeLabel.text = Formatter.changeDateForLocationTimeZone(for: timezone)
        //we have just logo name, i think, more practice don't save image, and just keep it number and update it, when it needed
        let imageURL = URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")
        //Get image data in background queue
        DispatchQueue.global(qos: .background).async {
            guard let url = imageURL, let imageData = try? Data(contentsOf: url) else {return}
            DispatchQueue.main.async {
                self.logoImageView.isHidden = false
                self.logoImageView.image = UIImage(data: imageData)
            }
        }
    }
    
    @objc func updateData() {
        //here i'm updating data, when user stay in detail vc
        guard let weatherInfo = currentWeatherInfo else {return}
        
        var query = [String: String]()
        // here i check, if data get with location, and check, if core location is on. I don't wanna stay old location information, because it can be confused for user
        if weatherInfo.isLocationSearch && locationService.locationAuthStatus == .alllow && locationService.latitude != nil {
            query = ["lat": locationService.latitude!, "lon": locationService.longitude!, "appid": "6ba713b340e3501610cdeb5793382e29"]
            isLocation = true
        } else if weatherInfo.isLocationSearch {
            // if location is off, just back user to city list
            self.navigationController?.popViewController(animated: true)
        } else {
            // else, just update with name.
            query = ["q": weatherInfo.name, "appid": "6ba713b340e3501610cdeb5793382e29"]
        }
        print(query)
        fetchingData(with: query)
    }
    
    //MARK: - Network helper
    private func fetchingData(with query: [String: String]) {
        self.weatherInfoController.fetchWeatherRequestController(query: query, success: { [weak self](weatherInfo) in
            guard let self = self, var currentWeatherInfo = self.currentWeatherInfo else {return}
            currentWeatherInfo.coord = weatherInfo.coord
            currentWeatherInfo.name = weatherInfo.name
            currentWeatherInfo.main = weatherInfo.main
            currentWeatherInfo.weather = weatherInfo.weather
            currentWeatherInfo.isLocationSearch = self.isLocation
            self.updateUI(icon: weatherInfo.weather[0].icon, timezone: weatherInfo.timezone, city: weatherInfo.name)
            self.delegate?.updateWeatherDataInStaticTableView(with: weatherInfo)
            
            //Save data
            guard let currentWeatherIndex = self.currentWeatherIndex else {return}
            self.weatherList[currentWeatherIndex] = currentWeatherInfo
            self.fileManager.saveWeatherListCities(list: self.weatherList)
        }) { (error) in
            DispatchQueue.main.async {
                self.updateUI(icon: self.currentWeatherInfo!.weather[0].icon, timezone: self.currentWeatherInfo!.timezone, city: self.currentWeatherInfo!.name)
            }
        }
    }
}

//MARK: - Location Manager Delegate
extension DetailWeatherViewController: LocationServiceDelegate {
     // just update latitude and longitude
    func locationManagerGetLocation(latitude: String, longitude: String) {
        guard let weatherInfo = currentWeatherInfo else {return}
        if weatherInfo.isLocationSearch {
            let query = ["lat": latitude, "lon": longitude, "appid": "6ba713b340e3501610cdeb5793382e29"]
            fetchingData(with: query)
        }
        
    }

}





