//
//  WeatherService.swift
//  WeatherSky
//
//  Created by Tony Merante on 10/4/16.
//  Copyright © 2016 Tony Merante. All rights reserved.
//

import Foundation
import CoreLocation

typealias ApiDataCompletion = ( (WeatherServiceResult) -> Void )
typealias AddressCompletion = ( (WeatherServiceResult) -> Void )
struct WeatherService {
    
    private enum endPoints {
        var key: String  {
            return "5be524e76c3f2edd7950e90d8072c885"
        }
        case searchByLatitudeAndLongitude(Double, Double)
        
        var url: URL {
            switch self {
            case .searchByLatitudeAndLongitude(let location) :
                return URL(string: "https://api.forecast.io/forecast/\(key)/\(location.0),\(location.1)")!
            }
        }
    }
    
    
    var latitude = 37.8267
    var longitude = -122.423
    
    init() {
    }
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    // MARK: fetchWeatherData
    func fetchWeatherData(byLatitude lat: Double, andLongitude long:Double, completion: @escaping ApiDataCompletion) {
        let session = URLSession.shared
        var forcasts:Forcasts?
        let dataTask = session.dataTask(with: endPoints.searchByLatitudeAndLongitude(lat,long).url) { data, response, error in
            do {
                
                
                let jsonDictionary: AnyObject! = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject!
                guard let dict = jsonDictionary as? Dictionary<String, AnyObject> else {
                    throw WeatherServiceResult.invalidJSON
                    
                }
                
                forcasts = Forcasts(json: dict)
                completion(.success(forcasts))
                
            }
            catch _ as WeatherServiceResult {
                completion(WeatherServiceResult.invalidJSON)
            }
            catch {
                
            }
        }
        
        dataTask.resume()
        
    }
    
    // MARK: transformToAddress
    func transformToAddress(fromLocation: CLLocation, completion: @escaping ApiDataCompletion) {
        CLGeocoder().reverseGeocodeLocation(fromLocation) { (placemarks, error)  in
            
            if let e = error  {
                // we have an error
                completion(.error(e))
                return
                
            }
            
            guard let p = placemarks, let pm = p.first  else  {
                completion(.noAddress)
                return
            }
            
            completion(.addressLocated(pm))
        }
    }
    
}
