//
//  ErrorView.swift
//  Minimal Weather
//
//  Created by Кирилл Лежнин on 9/3/19.
//  Copyright © 2019 Кирилл Лежнин. All rights reserved.
//

import UIKit

class ErrorView: UIView {
    private var topConstraint: NSLayoutConstraint?
    private var errorView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var isAnimationRunning = false
    
    private var errorLabel: UILabel = {
        let label = UILabel()
        label.text = ""
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
        topConstraint = errorView.topAnchor.constraint(equalTo: topAnchor, constant: 0)
//        errorView.addSubview(errorLabel)
        NSLayoutConstraint.activate([
//            errorView.topAnchor.constraint(equalTo: topAnchor),
            topConstraint!,
            errorView.widthAnchor.constraint(equalTo: widthAnchor),
            errorView.heightAnchor.constraint(equalToConstant: 40),
            errorLabel.bottomAnchor.constraint(equalTo: errorView.bottomAnchor),
            errorLabel.centerXAnchor.constraint(equalTo: errorView.centerXAnchor)
            ])
        
        
    }
    
    func triggerAnimation() {
        switch ErrorHandling.networkStatus {
        case .NetworkError:
            errorLabel.text = "Network Error"
        case .DecodingError:
            errorLabel.text = "Error with decoding city"
        default:
            errorLabel.text = "Hello"
        }
        UIView.animate(withDuration: 1, animations:  {
            self.isAnimationRunning = true
            self.topConstraint!.constant = 30
            self.layoutIfNeeded()
        }, completion: {_ in
            UIView.animate(withDuration: 1, delay: 2, animations: {
                self.topConstraint!.constant = 0
                self.layoutIfNeeded()
            }, completion: {_ in
                self.isAnimationRunning = false
            })
        })
    }
}
