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
    @IBOutlet weak var cellView: UIView!
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
    
    func animateShowCell() {
        let cellHeight: CGFloat = 40
        transform = CGAffineTransform(translationX: 0, y: 0)
        alpha = 0
        UIView.animate(withDuration: 1.6, animations:  {
            print("I'm work")
            self.transform = CGAffineTransform(translationX: 0, y: cellHeight)
            self.alpha = 1
        }, completion: {_ in
            UIView.animate(withDuration: 1.6, animations: {
                print("I'm too")
                self.transform = CGAffineTransform(translationX: 0, y: 0)
                self.alpha = 0
            })
        } )
    }
    
    func animateEndCell() {
        
    }
    
}
