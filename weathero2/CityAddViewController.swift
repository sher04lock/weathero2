import UIKit
import CoreLocation

class CityAddViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    var foundCities: [CityModel] = []
    var selectedCities: [CityModel] = []
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var toggleStack: UIStackView!
    @IBOutlet weak var hintLabel: UILabel!
    
    @IBOutlet weak var cityName: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var toggleSwitch: UISwitch!
    
    @IBOutlet weak var locationStackView: UIStackView!
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var searchByLocationButton: UIButton!
    
    var locationManager: CLLocationManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusLabel.text = ""
        toggleStack.isHidden = true
        hintLabel.text = ""
        tableView.tableFooterView = UIView(frame: .zero)
        searchButton.layer.cornerRadius = 5.0
        locationStackView.isHidden = true
        searchByLocationButton.isHidden = true
        
        getLocation()
    }
    
    @IBAction func onSearchByLocationButtonClick(_ sender: UIButton) {
        print("searching")
        self.showSearchPending()
        
        let forecastService = ForecastService()
        forecastService.findCities(coordinate: self.locationManager.location!.coordinate, callback: onDataFetched)
    }
    
    @IBAction func onSearchButtonClick(_ sender: UIButton) {
        self.showSearchPending()
        
        let forecastService = ForecastService()
        forecastService.findCities(name: self.cityName.text!, callback: onDataFetched)
    }
    
    func showSearchPending() {
        searchButton.isEnabled = false
        searchByLocationButton.isEnabled = false
        searchButton.setTitle("Searching...", for: .normal)
    }
    
    func onDataFetched(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void {
        guard let data = data,
            error == nil else {
                return
        }
        
        saveFoundCities(data: data)
        
        DispatchQueue.main.async {
            self.searchButton.isEnabled = true
            self.searchByLocationButton.isEnabled = true
            self.searchButton.setTitle("Search", for: .normal)
            self.updateView()
        }
    }
    
    func saveFoundCities(data: Data) {
        do {
            self.foundCities = []
            if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[String: Any]] {
                
                for case let cityJSON in json {
                    if let foundCity = CityModel(json: cityJSON) {
                        print("adding city \(foundCity.name)")
                        self.foundCities.append(foundCity)
                    }
                }
                print ("found cities saved")
                
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func updateView() {
        if self.foundCities.isEmpty {
            print ("Couldn't find matching city")
            self.statusLabel.text = "I couldn't find anything :("
            self.toggleStack.isHidden = true
        } else {
            self.statusLabel.text = "Found cities:"
            if (self.foundCities.count > 1) {
                self.toggleStack.isHidden = false
                self.hintLabel.text = "(select everything you need and click 'Save'!)"
            }
        }
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let cityEntry = foundCities[indexPath.row]
       
        cell.textLabel!.text = cityEntry.name
        
        if let distance = cityEntry.distance {
            cell.detailTextLabel!.text = "\(distance / 1000) km"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.foundCities.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.toggleSwitch.isOn {
            self.toggleCheckMark(tableView: tableView, indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if !self.toggleSwitch.isOn {
            self.toggleCheckMark(tableView: tableView, indexPath: indexPath)
        }
        
        return indexPath
    }
    
    func toggleCheckMark(tableView: UITableView, indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if cell?.accessoryType == .checkmark {
            print("deselecting \(foundCities[indexPath.row])")
            
            cell?.accessoryType = .none
            selectedCities = selectedCities.filter {$0.id != foundCities[indexPath.row].id}
        } else {
            print("selecting \(foundCities[indexPath.row])")
            cell?.accessoryType = .checkmark
            selectedCities.append(foundCities[indexPath.row])
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if let ident = identifier {
            if ident == "cellSegue" {
                return !self.toggleSwitch.isOn
            }
        }
        return true
    }
    
    // Location
    func getLocation() {
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            if let location = locationManager.location {
                CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                    
                    guard let placemark = placemarks?.first else {
                        let errorString = error?.localizedDescription ?? "Unexpected Error"
                        print("[Uops!] location reverse geocoding went wrong: \(errorString)")
                        return
                    }
                    
                    let humanReadibleLocation = HumanReadibleLocation(with: placemark)
                    
                    self.currentLocationLabel.text = String(describing: humanReadibleLocation)
                    self.locationStackView.isHidden = false
                    self.searchByLocationButton.isHidden = false
                }
            }
        }
    }
}
