//
//  ErrorView.swift
//  Minimal Weather
//
//  Created by Кирилл Лежнин on 9/3/19.
//  Copyright © 2019 Кирилл Лежнин. All rights reserved.
//

import UIKit

class ErrorView: UIView {
    private var heightConstraint: NSLayoutConstraint?
    
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
        heightConstraint = errorView.heightAnchor.constraint(equalToConstant: 0)
        
        
//        errorView.addSubview(errorLabel)
        NSLayoutConstraint.activate([
//            errorView.topAnchor.constraint(equalTo: topConstraint),
//            topConstraint!,
            layoutMarginsGuide.bottomAnchor.constraint(equalTo: errorView.bottomAnchor),
            errorView.widthAnchor.constraint(equalTo: widthAnchor),
            heightConstraint!,
            errorLabel.bottomAnchor.constraint(equalTo: errorView.bottomAnchor),
            errorLabel.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: errorView.centerYAnchor)
            ])
        
        
    }
    
    func triggerAnimation(error: Error) {
        switch error as! NetworkError {
        case .FetchingError:
            errorLabel.text = "Network Error"
        case .DecodingError:
            errorLabel.text = "Error with decoding city"
        }
        UIView.animate(withDuration: 1, animations:  {
            self.isAnimationRunning = true
            self.heightConstraint?.constant = 40
            self.layoutIfNeeded()
        }, completion: {_ in
            UIView.animate(withDuration: 1, delay: 2, animations: {
                self.heightConstraint?.constant = 0
                self.layoutIfNeeded()
            }, completion: {_ in
                self.errorLabel.text = ""
                self.isAnimationRunning = false
            })
        })
    }
}
