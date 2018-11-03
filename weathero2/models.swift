import Foundation

struct ForecastModel {
    let city: CityModel
    let weatherList: [WeatherModel]
    
    init(city: CityModel, weatherList: [WeatherModel]) {
        self.city = city
        self.weatherList = weatherList
    }
}

struct WeatherModel {
    let date: Date?
    let weatherType: String
    let weatherTypeAbbreviaton: String
    let currentTemp: Double
    let minTemp: Double
    let maxTemp: Double
    let wind: (speed: Double, direction: String)
    let airPressure: Double
    let humidity: Double
}

extension WeatherModel {
    init?(json: [String: Any]) {
        guard let date = json["applicable_date"] as? String,
            let weatherType = json["weather_state_name"] as? String,
            let weatherTypeAbbreviation = json["weather_state_abbr"] as? String,
            let currentTemp = json["the_temp"] as? Double,
            let minTemp = json["min_temp"] as? Double,
            let maxTemp = json["max_temp"] as? Double,
            let windSpeed = json["wind_speed"] as? Double,
            let windDirection = json["wind_direction_compass"] as? String,
            let airPressure = json["air_pressure"] as? Double,
            let humidity = json["humidity"] as? Double
            else {
                return nil
        }
        self.date = Utils.parseDate(dateString: date)
        self.weatherType = weatherType
        self.weatherTypeAbbreviaton = weatherTypeAbbreviation
        self.currentTemp = currentTemp
        self.minTemp = minTemp
        self.maxTemp = maxTemp
        self.wind = (windSpeed, windDirection)
        self.humidity = humidity
        self.airPressure = airPressure
    }
}

struct CityModel {
    let name: String
    let id: Int
    let coords: Coords
    
    init?(json: [String: Any]) {
        print(json)
        guard let name = json["title"] as? String,
            let id = json["woeid"] as? Int,
            let latt_long = json["latt_long"] as? String
            else {
                return nil
        }
        self.name = name
        self.id = id
        
        self.coords = extractCoordsFrom(string: latt_long)
    }
}

struct Coords {
    let latitude: Double
    let longitude: Double
    
    init(_ latitude: Double, _ longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

func extractCoordsFrom(string: String) -> Coords {
    let latt_longArray = string.components(separatedBy: ",")
    
    if let latitude = Double(latt_longArray[0]),
        let longitude = Double(latt_longArray[1]) {
        return Coords(latitude, longitude)
    }
    
    return Coords(0, 0)
}
