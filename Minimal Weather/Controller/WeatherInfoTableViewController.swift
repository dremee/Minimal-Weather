//
//  WeatherInfoTableViewController.swift
//  Minimal Weather
//
//  Created by Кирилл Лежнин on 9/6/19.
//  Copyright © 2019 Кирилл Лежнин. All rights reserved.
//

import UIKit

class WeatherInfoTableViewController: UITableViewController, DetailWeatherDelegate {
    
    //MARK: - outlets
    @IBOutlet weak var currentWeatherTempLabel: UILabel!
    @IBOutlet weak var minimunTempLabel: UILabel!
    @IBOutlet weak var maximumTempLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var windDegreeLabel: UILabel!
    
    //MARK: - view lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }

    
    //MARK: - WeatherDataDelegate
    func updateWeatherDataInStaticTableView(with data: DetailWeatherInfoDataViewModel) {
        currentWeatherTempLabel.text = data.temp
        minimunTempLabel.text = data.minTemp
        maximumTempLabel.text = data.maxTemp
        windSpeedLabel.text = data.windSpeed
        windDegreeLabel.text = data.windDegree
    }


}
