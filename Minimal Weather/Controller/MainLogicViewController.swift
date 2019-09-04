//
//  MainLogicViewController.swift
//  Minimal Weather
//
//  Created by Кирилл Лежнин on 9/4/19.
//  Copyright © 2019 Кирилл Лежнин. All rights reserved.
//

import UIKit
import CoreLocation
// This view controller will controll all compare logic from two controllers
class MainLogicViewController: UIViewController {
    let locationManager = CLLocationManager()
    var locationAuthStatus = ErrorHandling.LocationAuthStatus.denied
    var latitude: String?
    var longitude: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initLocationManager()
        checkLocationStatus()
        
    }
    

    

}

extension MainLogicViewController: CLLocationManagerDelegate {
    func checkLocationStatus() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                locationAuthStatus = .denied
            case .authorizedAlways, .authorizedWhenInUse:
                locationAuthStatus = .alllow
            }
        }
    }
    
    func initLocationManager() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.startUpdatingLocation()
    }
}
