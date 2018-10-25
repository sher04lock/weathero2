//
//  MasterViewController.swift
//  weathero2
//
//  Created by John Doe on 20/10/2018.
//  Copyright © 2018 John Doe. All rights reserved.
//

import UIKit


class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [ForecastModel]()
    var forecasts: [ForecastModel] = []
    var savedCities: [String] = [WARSAW_WOEID, DUBLIN_WOEID, BERLIN_WOEID]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadForecasts()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem

        //	let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        //navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    func loadForecasts() {
        let forecastService = ForecastService()
        
        for city in self.savedCities {
            forecastService.getForecast(cityCode: city, callback: onDataFetched)
        }
    }
    
    func onDataFetched(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void {
        guard let data = data,
            error == nil else {
                return
        }
        
        saveForecasts(data: data)
        
        DispatchQueue.main.async {
            self.updateView()
        }
    }
    
    func saveForecasts(data: Data) {
        print("saving forecasts")
        var weatherList = [WeatherModel]()
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                if let weathers = json["consolidated_weather"] as? [[String: Any]] {
                    for case let weather in weathers {
                        if let weatherModel = WeatherModel(json: weather) {
                            weatherList.append(weatherModel)
                        }
                    }
                }
                if let city = json["title"] as? String {
                    self.forecasts.append(ForecastModel(city: city, weatherList: weatherList))
                    print("forecast saved")
                }
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func updateView() {
        print("updating view")
        tableView.reloadData()
    }

    @objc
    func insertNewObject(_ sender: Any) {
        //objects.insert(NSDate(), at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let forecast = forecasts[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! ViewController
                controller.weatherList = forecast.weatherList
                controller.city = forecast.city
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecasts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let cityEntry = forecasts[indexPath.row]
        cell.textLabel!.text = cityEntry.city
        cell.detailTextLabel!.text = Utils.formatNumber(cityEntry.weatherList[0].currentTemp) + CELCIUS_DEGREE
        cell.imageView!.image = UIImage(named: cityEntry.weatherList[0].weatherTypeAbbreviaton)
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            forecasts.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    @IBAction func cancel(segue: UIStoryboardSegue) {
    }
    
    
    @IBAction func done(segue: UIStoryboardSegue) {
        let cityAddVC = segue.source as! CityAddViewController
      let newCity = cityAddVC.city
        //let newForecast: ForecastModel = ForecastModel(location: newCity, weatherType: "c", currentTemp: 12.2)
        //objects.insert(newForecast, at: 0)
        tableView.reloadData()
    }


}

