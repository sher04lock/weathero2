import UIKit
import ISPageControl

class DetailViewController: UIViewController {
    
    var weatherList: [WeatherModel] = []
    var currentWeatherIndex = 0
    var city: CityModel!
    
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weatherTypeField: UILabel!
    @IBOutlet weak var lowestTemp: UITextField!
    @IBOutlet weak var highestTemp: UITextField!
    @IBOutlet weak var wind: UITextField!
    @IBOutlet weak var airPressure: UITextField!
    @IBOutlet weak var humidity: UITextField!
    
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var pageIndicator: ISPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()      
        updateView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMap" {
            let controller = segue.destination as! MapViewController
            controller.coordinate = self.city.coordinate
            }
    }
    
    func initialSetup() {
        previousButton.isEnabled = false
        nextButton.isEnabled = false
    }
    
    func updateView() {
        if (self.weatherList.count == 0) {
            return;
        }
        
        let forecast = self.weatherList[currentWeatherIndex]
        
        self.navigationItem.title = city.name
        
        setForecastDate(forecast.date)
        setImage(forecast.weatherTypeAbbreviaton)
        
        weatherTypeField.text = forecast.weatherType
        lowestTemp.text = Utils.formatNumber(forecast.minTemp) + CELCIUS_DEGREE
        highestTemp.text = Utils.formatNumber(forecast.maxTemp) + CELCIUS_DEGREE
        wind.text = "\(Utils.formatNumber(forecast.wind.speed)) km/h \(forecast.wind.direction)"
        airPressure.text = "\(Utils.formatNumber(forecast.airPressure)) hPa"
        humidity.text = "\(Utils.formatNumber(forecast.humidity))%"
        
        updateNavigationButtonsStates()
    }
    
    func updateNavigationButtonsStates() {
        previousButton.isEnabled = currentWeatherIndex > 0
        nextButton.isEnabled = currentWeatherIndex + 1 < weatherList.count
    }
    
    func setForecastDate(_ date: Date?) -> Void {
        if (date == nil) {
            dateLabel.text = ""
            return
        }
        let formatted = Utils.formatDate(date!)
        dateLabel!.text = formatted
    }
    
    func setImage(_ weatherState: String?) -> Void {
        if (weatherState != nil) {
            weatherImage.image = UIImage(named: weatherState!)
        }
    }
    
    
    @IBAction func goToPrevious(_ sender: Any) {
        currentWeatherIndex = currentWeatherIndex - 1
        pageIndicator.currentPage = currentWeatherIndex;
        updateView()
    }
    
    @IBAction func goToNext(_ sender: Any) {
        currentWeatherIndex = currentWeatherIndex + 1
        pageIndicator.currentPage = currentWeatherIndex;
        updateView()
    }
}
