//
//  ErrorViewCell.swift
//  Minimal Weather
//
//  Created by Кирилл Лежнин on 9/2/19.
//  Copyright © 2019 Кирилл Лежнин. All rights reserved.
//

import UIKit

class ErrorViewCell: UITableViewCell {

    @IBOutlet weak var errorLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateLabel() {
        switch ErrorHandling.networkStatus {
        case .NetworkError:
            errorLabel.text = "Error with networking"
        case .DecodingError:
            errorLabel.text = "Error with city name or server is not response"
        default:
            return
        }
    }
    
}
