import UIKit

class CityAddViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var foundCities: [CityModel] = []
    var selectedCities: [CityModel] = []
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var toggleStack: UIStackView!
    @IBOutlet weak var hintLabel: UILabel!
    
    @IBOutlet weak var cityName: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var toggleSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusLabel.text = ""
        toggleStack.isHidden = true
        hintLabel.text = ""
        tableView.tableFooterView = UIView(frame: .zero)
        searchButton.layer.cornerRadius = 5.0
    }
    
    @IBAction func onSearchButtonClick(_ sender: UIButton) {
        print(self.cityName.text!)
        let forecastService = ForecastService()
        forecastService.searchCity(query: self.cityName.text!, callback: onDataFetched)
        
        searchButton.isEnabled = false
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
                    
                    print ("found cities saved")
                    print(foundCities)
                }
                
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
        let cityEntry = foundCities[indexPath.row].name
        cell.textLabel!.text = cityEntry
        
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
}
