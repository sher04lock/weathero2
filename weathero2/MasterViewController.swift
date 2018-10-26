import UIKit


class MasterViewController: UITableViewController {
    
    var objects = [ForecastModel]()
    var forecasts: [ForecastModel] = []
    var forecasts2: [Int: ForecastModel] = [:]
    var savedCities: [Int] = [WARSAW_WOEID, DUBLIN_WOEID, BERLIN_WOEID]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: .zero)
        navigationItem.leftBarButtonItem = editButtonItem
        
        self.loadForecasts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    func loadForecasts() {
        let forecastService = ForecastService()
        
        for city in self.savedCities {
            if forecasts2[city] == nil {
                forecastService.getForecast(cityCode: city, callback: onDataFetched)
            }
        }
    }
    
    func loadForecast(cityId: Int) {
        let forecastService = ForecastService()
        forecastService.getForecast(cityCode: cityId, callback: onDataFetched)
    }
    
    func onDataFetched(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void {
        guard let data = data,
            error == nil else {
                return
        }
        
        saveForecast(data: data)
        
        DispatchQueue.main.async {
            self.updateView()
        }
    }
    
    func saveForecast(data: Data) {
        print("saving forecast")
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
                
                if let city = CityModel(json: json) {
                    self.forecasts2[city.id] = ForecastModel(city: city, weatherList: weatherList)
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
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let forecastId = savedCities[indexPath.row]
                if let forecast = forecasts2[forecastId] {
                    let controller = (segue.destination as! UINavigationController).topViewController as! ViewController
                    controller.weatherList = forecast.weatherList
                    controller.city = forecast.city.name
                    controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                    controller.navigationItem.leftItemsSupplementBackButton = true
                }
            }
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecasts2.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if let cityEntry = forecasts2[savedCities[indexPath.row]] {
            cell.textLabel!.text = cityEntry.city.name
            cell.detailTextLabel!.text = Utils.formatNumber(cityEntry.weatherList[0].currentTemp) + CELCIUS_DEGREE
            cell.imageView!.image = UIImage(named: cityEntry.weatherList[0].weatherTypeAbbreviaton)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deletedCity = savedCities.remove(at: indexPath.row)
            forecasts2[deletedCity] = nil
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
        let selectedCities = cityAddVC.selectedCities
        print("you've selected cities: \(selectedCities.map{ $0.name })")
        self.savedCities.insert(contentsOf: selectedCities.map{$0.id}, at: 0)
        for city in selectedCities {
            self.loadForecast(cityId: city.id)
        }
        
        //let newForecast: ForecastModel = ForecastModel(location: newCity, weatherType: "c", currentTemp: 12.2)
        //objects.insert(newForecast, at: 0)
        tableView.reloadData()
    }
    
}

