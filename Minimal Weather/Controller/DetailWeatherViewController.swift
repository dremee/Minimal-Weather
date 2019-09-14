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
    func updateWeatherDataInStaticTableView(with data: DetailWeatherInfoDataViewModel)
}

class DetailWeatherViewController: UIViewController {
    //Delegate
    var delegate: DetailWeatherDelegate?
    //MARK: - Properties
    private var timer = Timer()

    private var dataUpdater = DataUpdater.shared
    var currentWeatherIndex: Int?
    
    //MARK: - Outlets
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    
    //MAKR: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let currentWeatherIndex = currentWeatherIndex {
            title = dataUpdater.cityWeatherList[currentWeatherIndex].name
            let weatherViewModel = WeatherDataFactory.detailViewModel(for: dataUpdater.cityWeatherList[currentWeatherIndex])
            self.updateUI(weatherData: weatherViewModel)
            
            
            
            delegate?.updateWeatherDataInStaticTableView(with: weatherViewModel.detailWeatherInfoDataViewModel)
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
    private func updateUI(weatherData: DetailWeatherDataViewModel) {
        self.title = weatherData.city
        self.cityLabel.text = weatherData.city
        self.currentTimeLabel.text = weatherData.time
        //we have just logo name, i think, more practice don't save image, and just keep it number and update it, when it needed
        let imageURL = URL(string: "https://openweathermap.org/img/wn/\(weatherData.icon)@2x.png")
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
        
        dataUpdater.updateData(success: {
            let weatherDataModel = WeatherDataFactory.detailViewModel(for: self.dataUpdater.cityWeatherList[self.currentWeatherIndex!])
            self.updateUI(weatherData: weatherDataModel)
        }) { (error) in
            self.navigationController?.popViewController(animated: true)
        }
    }
}


