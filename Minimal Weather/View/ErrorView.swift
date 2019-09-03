//
//  ErrorView.swift
//  Minimal Weather
//
//  Created by Кирилл Лежнин on 9/3/19.
//  Copyright © 2019 Кирилл Лежнин. All rights reserved.
//

import UIKit

class ErrorView: UIView {

    private var errorView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var errorLabel: UILabel = {
        let label = UILabel()
        switch ErrorHandling.networkStatus {
        case .NetworkError:
            label.text = "Network Error"
        case .DecodingError:
            label.text = "Error with decoding city"
        default:
            break
        }
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadView()
    }
    
    func loadView() {
        addSubview(errorView)
        errorView.addSubview(errorLabel)
        var topConstraint = errorView.topAnchor.constraint(equalTo: topAnchor, constant: 0)
//        errorView.addSubview(errorLabel)
        NSLayoutConstraint.activate([
//            errorView.topAnchor.constraint(equalTo: topAnchor),
            topConstraint,
            errorView.widthAnchor.constraint(equalTo: widthAnchor),
            errorView.heightAnchor.constraint(equalToConstant: 40)
            ])
        UIView.animate(withDuration: 1, animations:  {
            topConstraint.constant = 30
            self.layoutIfNeeded()
        }, completion: {_ in
            UIView.animate(withDuration: 1, delay: 2, animations: {
                topConstraint.constant = 0
                self.layoutIfNeeded()
            })
            
        })
        
    }
}
