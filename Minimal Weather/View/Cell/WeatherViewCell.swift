//
//  WeatherViewCell.swift
//  Minimal Weather
//
//  Created by Кирилл Лежнин on 8/30/19.
//  Copyright © 2019 Кирилл Лежнин. All rights reserved.
//

import UIKit

class WeatherViewCell: UITableViewCell {
    
    
    @IBOutlet weak var weatherView: UIView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateCell(for result: WeatherDataModel) {
        cityLabel.text = result.name
        weatherLabel.text = "\(result.main.celsius)"
        timeLabel.text = Formatter.changeDateForLocationTime(for: result.timezone)
    }
    
}
