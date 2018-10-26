//
//  ForecastService.swift
//  weathero2
//
//  Created by John Doe on 24/10/2018.
//  Copyright © 2018 John Doe. All rights reserved.
//

import Foundation
let WARSAW_WOEID = 523920
let BERLIN_WOEID = 638242
let DUBLIN_WOEID = 560743

class ForecastService {
    
    func getForecast(cityCode: Int = WARSAW_WOEID, callback: @escaping (Data?, URLResponse?, Error?) -> Void) {
        print("Downloading forecast for \(cityCode)")
        self.makeRequest(urlString: "https://www.metaweather.com/api/location/\(cityCode)", callback: callback)
    }
    
    func searchCity(query: String, callback: @escaping (Data?, URLResponse?, Error?) -> Void) {
        print("Looking for city matching \(query)")
        self.makeRequest(urlString: "https://www.metaweather.com/api/location/search/?query=\(query)", callback: callback)
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
}
