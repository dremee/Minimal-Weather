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

class DetailWeatherViewController: MainLogicViewController {
    //Delegate
    var delegate: DetailWeatherDelegate?
    //MARK: - Properties
    var currentWeatherInfo: WeatherDataModel?
    
    
    //MARK: - Networking
    private let weatherInfoController = WeatherInfoController()
    
    //MARK: - Outlets
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    
    //MAKR: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let currentView = currentWeatherInfo {
            title = currentView.name
            self.updateUI(icon: currentView.weather[0].icon, timezone: currentView.timezone, city: currentView.name)
            
            delegate?.updateWeatherDataInStaticTableView(with: self.currentWeatherInfo!)
            reloadDataInTime(time: 10, repeats: true, callback: updateData)
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
        if weatherInfo.isLocationSearch && locationAuthStatus == .alllow {
            query = ["lat": latitude!, "lon": longitude!, "appid": "6ba713b340e3501610cdeb5793382e29"]
        } else if weatherInfo.isLocationSearch {
            // if location is off, just back user to city list
            self.navigationController?.popViewController(animated: true)
        } else {
            // else, just update with name.
            query = ["q": weatherInfo.name, "appid": "6ba713b340e3501610cdeb5793382e29"]
        }
        
        self.weatherInfoController.fetchWeatherRequestController(query: query) { [weak self](weatherInfo) in

            guard let self = self else {return}
            
            if let currentView = weatherInfo {
                //have to update data, without updating isLocationSearch for control next updating. If i just make currentWeatherLocation = currentView, i lost my isLocationSearch status
                self.currentWeatherInfo?.coord = currentView.coord
                self.currentWeatherInfo?.name = currentView.name
                self.currentWeatherInfo?.main = currentView.main
                self.currentWeatherInfo?.weather = currentView.weather
                self.updateUI(icon: currentView.weather[0].icon, timezone: currentView.timezone, city: currentView.name)
                self.delegate?.updateWeatherDataInStaticTableView(with: currentView)
            } else {
                // if user have problem with network, we staying in the current vc and show him last saved information
                DispatchQueue.main.async {
                    self.updateUI(icon: self.currentWeatherInfo!.weather[0].icon, timezone: self.currentWeatherInfo!.timezone, city: self.currentWeatherInfo!.name)
                }
                
            }
            
        }
    }
}

//MARK: - Location Manager Delegate
extension DetailWeatherViewController {

    
    // just update latitude and longitude
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            latitude = String(location.coordinate.latitude)
            longitude = String(location.coordinate.longitude)
        }
    }
}
