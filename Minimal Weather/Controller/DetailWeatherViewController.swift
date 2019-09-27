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

    private var dataUpdater = DataUpdaterService.shared
    private var presenter = Presenter()
    var currentWeatherIndex: Int?
    
    //MARK: - Outlets
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    
    //MAKR: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let currentWeatherIndex = currentWeatherIndex {
            title = presenter.returnDetailViewModel()[currentWeatherIndex].city
            
            self.updateUI(weatherDataModel: presenter.returnDetailViewModel()[currentWeatherIndex])
            
            
            
            delegate?.updateWeatherDataInStaticTableView(with: presenter.returnDetailViewModel()[currentWeatherIndex].detailWeatherInfoDataViewModel)
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
    private func updateUI(weatherDataModel: DetailWeatherDataViewModel) {
        self.title = weatherDataModel.city
        self.cityLabel.text = weatherDataModel.city
        self.currentTimeLabel.text = weatherDataModel.time
        //we have just logo name, i think, more practice don't save image, and just keep it number and update it, when it needed
        let imageURL = URL(string: "https://openweathermap.org/img/wn/\(weatherDataModel.icon)@2x.png")
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
            let weatherDataModel = self.presenter.returnDetailViewModel()[self.currentWeatherIndex!]
            self.updateUI(weatherDataModel: weatherDataModel)
            self.delegate?.updateWeatherDataInStaticTableView(with: weatherDataModel.detailWeatherInfoDataViewModel)
        }) { (error) in
            self.navigationController?.popViewController(animated: true)
        }
    }
}


