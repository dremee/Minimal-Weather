//
//  WeatherInfoTableViewController.swift
//  Minimal Weather
//
//  Created by Кирилл Лежнин on 9/6/19.
//  Copyright © 2019 Кирилл Лежнин. All rights reserved.
//

import UIKit

class WeatherInfoTableViewController: UITableViewController {
    var data: WeatherDataModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        if let data = data {
            print(data)
        }
    }




}
