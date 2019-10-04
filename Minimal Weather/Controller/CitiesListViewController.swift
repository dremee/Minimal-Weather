//
//  CitiesListViewController.swift
//  Minimal Weather
//
//  Created by Кирилл Лежнин on 8/26/19.
//  Copyright © 2019 Кирилл Лежнин. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation


class CitiesListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - properties
    private var selectedWeatherIndex: Int?
    fileprivate var timer = Timer()
    private var presenter = CitiesListPresenter()
    
    //Create refresh control
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(updateWeather),
                                 for: .valueChanged)
        refreshControl.tintColor = UIColor(red: 240/255,
                                           green: 255/255,
                                           blue: 149/255,
                                           alpha: 1)
        return refreshControl
    }()
    
    //MARK: - Views
    fileprivate let selectedGrayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.darkGray
        return view
    }()
    
    // add error view and setup it
    private let errorView: ErrorView = {
        let view = ErrorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private func setupErrorView() {
        view.addSubview(errorView)
        NSLayoutConstraint.activate([
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            errorView.widthAnchor.constraint(equalTo: view.widthAnchor),
            errorView.heightAnchor.constraint(equalToConstant: 100)
            ])
    }
    
    //MARK: - View Lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //table view settings
        tableView.dataSource = self
        tableView.delegate = self
        //create footer bar, for not display empty cells
        tableView.tableFooterView = UIView()
        tableView.refreshControl = refreshControl
        //add weather custom cell
        let cellNib = UINib(nibName: "WeatherViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "WeatherViewCell")
        
        
        //Create add city button and add it like right bar button item
        let addCityButton = UIBarButtonItem(barButtonSystemItem: .add,
                                            target: self,
                                            action: #selector(addCity))
        self.navigationItem.rightBarButtonItem = addCityButton
        
        //Make safe unwrapping from file manager, and if it exist, update weather
        updateWeather()
        
        setupErrorView()
        
        
        //Reload data every 10 seconds
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(withTimeInterval: 10,
                                              repeats: true,
                                              block: { (_) in
                self.updateWeather()
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //check, if app is launch before, we update data form detail vc here
        let launchBefore = UserDefaults.standard.bool(forKey: "launchBefore")
        if launchBefore {
            print("Updating in viewwillappear")
            self.updateWeather()
            self.tableView.reloadData()
        } else {
            UserDefaults.standard.set(true, forKey: "launchBefore")
        }
        
    }
    
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetailSegue" {
            if let vc = segue.destination as? DetailWeatherViewController {
                vc.currentWeatherIndex = selectedWeatherIndex
            }
        }
    }
    
    //MARK: - Actions
    @objc private func addCity() {
            let alert = UIAlertController(title: "Find by city name",
                                          message: "Enter city name to find it's weather",
                                          preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            let okAction = UIAlertAction(title: "Find", style: .default) { [weak alert] (_) in
                    
                if let textField = alert?.textFields![0].text!,
                    textField.count > 0 {
                    var findCity = textField.trimmingCharacters(in: .whitespaces)
                    findCity = findCity.replacingOccurrences(of: " ", with: "+")
                    
                    self.presenter.addData(with: findCity, success: {
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }, failure: { error in
                        self.runErrorAnimation(error: error)
                    })
                    
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            present(alert, animated: true)
    }
    

    
    //MARK: - Helper
    
    //update weather list
    @objc private func updateWeather() {
        
        presenter.updateData(success: {
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }) { (error) in
            self.runErrorAnimation(error: error)
        }
    }
    
    //Actiovating of error view
    private func runErrorAnimation(error: Error) {
        DispatchQueue.main.async {
            self.errorView.handleErrorAnimation(error: error)
        }
    }
    
    

}

//MARK: - TableView Extension
extension CitiesListViewController: UITableViewDataSource, UITableViewDelegate {
    //MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.returnWeatherViewModelList().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherViewCell", for: indexPath) as! WeatherViewCell
        //Change selected view to dark grey
        cell.selectedBackgroundView = selectedGrayView
        
        let currentView = presenter.returnWeatherViewModelList()[indexPath.row]
        cell.updateCell(for: currentView)
        return cell
    }
    
    //MARK: - Table view delegate
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedWeatherIndex = indexPath.row
        performSegue(withIdentifier: "ShowDetailSegue", sender: nil)
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let cell = tableView.cellForRow(at: indexPath) as? WeatherViewCell
        cell?.weatherView.backgroundColor = .black
    }
    
    //If first row get with location, don't access user to delete it
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 && presenter.returnWeatherViewModelList()[0].isLocation {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            presenter.deleteData(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.reloadData()
        }
    }
}








