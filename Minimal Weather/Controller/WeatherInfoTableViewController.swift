//
//  WeatherInfoTableViewController.swift
//  Minimal Weather
//
//  Created by Кирилл Лежнин on 9/6/19.
//  Copyright © 2019 Кирилл Лежнин. All rights reserved.
//

import UIKit

class WeatherInfoTableViewController: UITableViewController {
    @IBOutlet weak var currentWeatherTempLabel: UILabel!
    @IBOutlet weak var minimunTempLabel: UILabel!
    @IBOutlet weak var maximumTempLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var windDegreeLabel: UILabel!
    
    var data: WeatherDataModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        if let data = data {
            print(data)
        }
        
        updateCells(with: data)
    }

    func updateCells(with data: WeatherDataModel?) {
        guard let data = data else { return }
        currentWeatherTempLabel.text = "\(data.main.celsius)"
        minimunTempLabel.text = "\(data.main.minCelsius)"
        maximumTempLabel.text = "\(data.main.maxCelsius)"
        windSpeedLabel.text = "\(data.wind.windSpeed)"
        windDegreeLabel.text = "\(data.wind.windDegree)"
    }
    



}
