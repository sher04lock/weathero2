//
//  ForecastService.swift
//  weathero2
//
//  Created by John Doe on 24/10/2018.
//  Copyright © 2018 John Doe. All rights reserved.
//

import Foundation
let WARSAW_WOEID = "523920"
let BERLIN_WOEID = "638242"
let DUBLIN_WOEID = "560743"

class ForecastService {
    
    func getForecast(cityCode: String = WARSAW_WOEID, callback: @escaping (Data?, URLResponse?, Error?) -> Void) {
        print("Downloading forecast for \(cityCode)")
        let url = URL(string: "https://www.metaweather.com/api/location/\(cityCode)")!
        
        let session = URLSession.shared
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: callback)
        
        task.resume()
    }
    
    func searchCity(query: String, callback: @escaping (Data?, URLResponse?, Error?) -> Void) {
        print("Looking for city matching \(query)")
        let url = URL(string: "https://www.metaweather.com/api/location/search/?query=\(query)")!
        
        let session = URLSession.shared
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: callback)
        
        task.resume()
    }
}
