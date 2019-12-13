import Foundation
import CoreLocation
import Alamofire

let WARSAW_WOEID = 523920
let BERLIN_WOEID = 638242
let DUBLIN_WOEID = 560743

class ForecastService {
    
    func getForecast(cityCode: Int = WARSAW_WOEID, callback: @escaping (Data?, URLResponse?, Error?) -> Void) {
        print("Downloading forecast for \(cityCode)")
        self.makeRequest(urlString: "https://www.metaweather.com/api/location/\(cityCode)", callback: callback)
    }
    
    func findCities(name query: String, callback: @escaping (Data?, URLResponse?, Error?) -> Void) {
        print("Looking for city matching \(query)")
        self.makeRequest(urlString: "https://www.metaweather.com/api/location/search/?query=\(query)", callback: callback)
    }
    
    // This one is using alamofire
    func searchCities(name query: String, completion: @escaping ([[String: Any]]) -> Void) {
        print("NEW!!!! Looking for city matching \(query)")
        self.makeRequestWithAlamofire(urlString: "https://www.metaweather.com/api/location/search/?query=\(query)", completion: completion)
    }
    
    func findCities(coordinate: CLLocationCoordinate2D, callback: @escaping (Data?, URLResponse?, Error?) -> Void) {
        print("Looking for city near \(coordinate)")
        let latt_long = "\(coordinate.latitude),\(coordinate.longitude)"
        self.makeRequest(urlString: "https://www.metaweather.com/api/location/search/?lattlong=\(latt_long)", callback: callback)
    }
    
    private func makeRequest(urlString: String, callback: @escaping (Data?, URLResponse?, Error?) -> Void) {
        if let escapedString = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
            let url = URL(string: escapedString)!
            let session = URLSession.shared
            let request = URLRequest(url: url)
            
            let task = session.dataTask(with: request as URLRequest, completionHandler: callback)
            
            task.resume()
        }
    }
   
    public func makeRequestWithAlamofire(urlString: String, completion: @escaping ([[String: Any]]) -> Void) {
        if let escapedString = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
            let url = URL(string: escapedString)!
            Alamofire.request(
                url,
                method: .get
            )
            .validate()
                .responseJSON { response in
                    guard response.result.isSuccess else {
                        print("Error while fetching data")
                            completion([])
                        return
                    }
                    
                    let value = response.result.value as! [[String: Any]];
                    
                    completion(value)
            }
        }
    }
}
