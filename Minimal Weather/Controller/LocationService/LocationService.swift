//
//  LocationService.swift
//  Minimal Weather
//
//  Created by Кирилл Лежнин on 9/9/19.
//  Copyright © 2019 Кирилл Лежнин. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationServiceDelegate {
    func locationManagerGetLocation(latitude: String, longitude: String)
}

class LocationService: NSObject, CLLocationManagerDelegate {
    var delegate: LocationServiceDelegate?
    var latitude: String?
    var longitude: String?
    var locationAuthStatus: LocationAuthStatus?
    private let locationManager: CLLocationManager = CLLocationManager()
    
    var currentLocation = CLLocation()
    
    static let shared: LocationService = {
        let instance = LocationService()
        return instance
    }()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
//        locationManager.distanceFilter = 100.0
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        //        locationManager.stopUpdatingLocation()
        if location.horizontalAccuracy > 0 {
            DispatchQueue.main.async {
                self.latitude = String(location.coordinate.latitude)
                self.longitude = String(location.coordinate.longitude)
                self.updateLocation(latitude: self.latitude!, longitude: self.longitude!)
            }
        }
    }
    
    private func updateLocation(latitude: String, longitude: String) {
        guard let delegate = self.delegate else {return}
        delegate.locationManagerGetLocation(latitude: latitude, longitude: longitude)
    }
    
    
}
