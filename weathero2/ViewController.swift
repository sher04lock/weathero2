//
//  ViewController.swift
//  Weathero
//
//  Created by Student on 11.10.2018.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit

let INCOMING_DATE_FORMAT = "yyyy-MM-dd";
let DISPLAY_DATE_FORMAT = "EEEE MMM d, YYYY"
let WARSAW_WOEID = "523920"


func parseDate(dateString: String, dateFormat: String = "yyyy-MM-dd") -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = dateFormat
    return formatter.date(from: dateString)
}


struct Forecast {
    let date: Date?
    let weatherType: String
    let weatherTypeAbbreviaton: String
    let minTemp: Double
    let maxTemp: Double
    let wind: (speed: Double, direction: String)
    let airPressure: Double
    let humidity: Double
}


extension Forecast {
    init?(json: [String: Any]) {
        guard let date = json["applicable_date"] as? String,
            let weatherType = json["weather_state_name"] as? String,
            let weatherTypeAbbreviation = json["weather_state_abbr"] as? String,
            let minTemp = json["min_temp"] as? Double,
            let maxTemp = json["max_temp"] as? Double,
            let windSpeed = json["wind_speed"] as? Double,
            let windDirection = json["wind_direction_compass"] as? String,
            let airPressure = json["air_pressure"] as? Double,
            let humidity = json["humidity"] as? Double
            else {
                return nil
        }
        
        self.date = parseDate(dateString: date)
        self.weatherType = weatherType
        self.weatherTypeAbbreviaton = weatherTypeAbbreviation
        self.minTemp = minTemp
        self.maxTemp = maxTemp
        self.wind = (windSpeed, windDirection)
        self.humidity = humidity
        self.airPressure = airPressure
        
    }
}

class ViewController: UIViewController {
    
    var forecasts: [Forecast] = [];
    var currentWeatherIndex = 0;
    
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weatherTypeField: UILabel!
    @IBOutlet weak var lowestTemp: UITextField!
    @IBOutlet weak var highestTemp: UITextField!
    @IBOutlet weak var wind: UITextField!
    @IBOutlet weak var airPressure: UITextField!
    @IBOutlet weak var humidity: UITextField!
    
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authorNameLabel.text = "Bartłomiej Gródek"
        initialSetup()
        getWeatherData(cityCode: WARSAW_WOEID);
    }
    
    func initialSetup() {
        previousButton.isEnabled = false
        nextButton.isEnabled = false
    }
    
    func getWeatherData(cityCode: String = WARSAW_WOEID) {
        let url = URL(string: "https://www.metaweather.com/api/location/\(cityCode)")!
        
        let session = URLSession.shared
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: onDataFetched)
        
        task.resume()
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
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                if let weathers = json["consolidated_weather"] as? [[String: Any]] {
                    for case let weather in weathers {
                        if let forecast = Forecast(json: weather) {
                            self.forecasts.append(forecast)
                        }
                    }
                }
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func updateView() {
        if (self.forecasts.count == 0) {
            return;
        }
        
        let forecast = self.forecasts[currentWeatherIndex]
        
        setForecastDate(forecast.date)
        setImage(forecast.weatherTypeAbbreviaton)
        
        weatherTypeField.text = forecast.weatherType
        lowestTemp.text = formatNumber(forecast.minTemp) + "°C"
        highestTemp.text = formatNumber(forecast.maxTemp) + "°C"
        wind.text = "\(formatNumber(forecast.wind.speed)) km/h \(forecast.wind.direction)"
        airPressure.text = "\(formatNumber(forecast.airPressure)) hPa"
        humidity.text = "\(formatNumber(forecast.humidity))%"
        
        updateNavigationButtonsStates()
    }
    
    func updateNavigationButtonsStates() {
        previousButton.isEnabled = currentWeatherIndex > 0
        nextButton.isEnabled = currentWeatherIndex + 1 < forecasts.count
    }
    
    func setForecastDate(_ date: Date?) -> Void {
        if (date == nil) {
            dateLabel.text = ""
            return
        }
        
        dateLabel.text = formatDate(date!)
    }
    
    func setImage(_ weatherState: String?) -> Void {
        if (weatherState != nil) {
            weatherImage.image = UIImage(named: weatherState!)
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter.string(from: date)
    }
    
    func formatNumber(_ number: Double?) -> String {
        if (number == nil) {
            return "-"
        }
        
        return NSString(format: "%.1f", number!) as String
    }
    
    @IBAction func goToPrevious(_ sender: Any) {
        currentWeatherIndex = currentWeatherIndex - 1
        updateView()
    }
    
    @IBAction func goToNext(_ sender: Any) {
        currentWeatherIndex = currentWeatherIndex + 1
        updateView()
    }
}
