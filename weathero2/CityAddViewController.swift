import UIKit
import CoreLocation

class CityAddViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    var foundCities: [CityModel] = []
    var selectedCities: [CityModel] = []
    var locationManager: CLLocationManager!
    
    @IBOutlet weak var locationStackView: UIStackView!
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var searchByLocationButton: UIButton!
    
    @IBOutlet weak var citySearchField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var toggleStack: UIStackView!
    @IBOutlet weak var multiselectLabel: UILabel!
    @IBOutlet weak var toggleSwitch: UISwitch!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusLabel.text = ""
        toggleStack.isHidden = true
        locationStackView.isHidden = true
        searchByLocationButton.isHidden = true
        
        tableView.tableFooterView = UIView(frame: .zero)
        searchButton.layer.cornerRadius = 5.0
        
        getLocation()
    }
    
    @IBAction func onSearchByLocationButtonClick(_ sender: UIButton) {
        print("searching")
        self.pending()
        
        let forecastService = ForecastService()
        forecastService.findCities(coordinate: self.locationManager.location!.coordinate, callback: onDataFetched)
    }
    
    @IBAction func onSearchButtonClick(_ sender: UIButton) {
        self.pending()
        
        let forecastService = ForecastService()
        forecastService.findCities(name: self.citySearchField.text!, callback: onDataFetched)
        forecastService.findCities2(name: self.citySearchField.text!) { value in
            print(value)
        }
    }
    
    @IBAction func onToggleChange(_ sender: UISwitch) {
        self.multiselectLabel.textColor = sender.isOn ? UIColor.black : UIColor.gray
        
        if (!sender.isOn) {
            deselectAll()
        }
    }
    
    func deselectAll() {
        for cell in tableView.visibleCells {
            cell.accessoryType = .none
        }
        self.selectedCities = []
    }
    
    func pending() {
        searchButton.isEnabled = false
        searchByLocationButton.isEnabled = false
        searchButton.setTitle("Searching...", for: .normal)
        
        clearTable()
    }
    
    func loadingFinished() {
        self.searchButton.isEnabled = true
        self.searchByLocationButton.isEnabled = true
        self.searchButton.setTitle("Search", for: .normal)
    }
    
    func clearTable() {
        self.foundCities = []
        self.tableView.reloadData()
    }
    
    func onDataFetched(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void {
        guard let data = data,
            error == nil else {
                return
        }
        
        saveFoundCities(data: data)
        
        DispatchQueue.main.async {
            self.loadingFinished()
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
        } else {
            self.statusLabel.text = ""
        }
        self.toggleStack.isHidden = foundCities.count <= 1
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let cityEntry = foundCities[indexPath.row]
       
        cell.textLabel!.text = cityEntry.name
        
        if let distance = cityEntry.distance {
            cell.detailTextLabel!.text = "\(distance / 1000) km"
        } else {
            cell.detailTextLabel!.text = ""
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
