//
//  Forcast.swift
//  WeatherSky
//
//  Created by Tony Merante on 10/4/16.
//  Copyright © 2016 Tony Merante. All rights reserved.
//

import Foundation


struct Forcast {
    var apparentTemperature: Double = 0.0
    var cloudCover: Double = 0.0
    var dewPoint: Double = 0.0
    var humidity: Double = 0.0
    var icon: String = "clear-day";
    var nearestStormBearing: Int = 0
    var nearestStormDistance: Int = 0
    var ozone: Double = 0.0
    var precipIntensity: Double = 0.0
    var precipProbability: Double = 0.0
    var pressure: Double = 0.0
    var summary: String = "Clear"
    var temperature: Double = 0.0
    var temperatureMin: Double = 0.0
    var temperatureMax: Double = 0.0
    var time: Double = 0.0
    var date = Date()
    var visibility: Double = 0.0
    var windBearing: Int = 0
    var windSpeed: Double = 0.0
    
    init() {}
    
    init(currently: Dictionary<String, AnyObject>) {
        self.cloudCover = currently["cloudCover"] as! Double
        self.dewPoint = currently["dewPoint"] as! Double
        self.humidity = currently["humidity"] as! Double
        self.icon = currently["icon"] as! String
        
        if let stormBearing = currently["nearestStormBearing"] as? Int {
            self.nearestStormBearing = stormBearing
        }
        
        
        self.ozone = currently["ozone"] as! Double
        self.precipIntensity = currently["precipIntensity"] as! Double
        self.precipProbability = currently["precipProbability"] as! Double
        self.pressure = currently["pressure"] as! Double
        self.summary = currently["summary"] as! String
        self.temperature = currently["temperature"] as! Double
        self.time = currently["time"] as! Double
        self.date = Date(timeIntervalSince1970: self.time)
        
        if let visibility = currently["visibility"] as? Double {
            self.visibility = visibility
        }
        
    }
    init(daily: Dictionary<String, AnyObject>) {
        self.cloudCover = daily["cloudCover"] as! Double
        self.dewPoint = daily["dewPoint"] as! Double
        self.humidity = daily["humidity"] as! Double
        self.icon = daily["icon"] as! String
        
        
        
        self.ozone = daily["ozone"] as! Double
        self.precipIntensity = daily["precipIntensity"] as! Double
        self.precipProbability = daily["precipProbability"] as! Double
        self.pressure = daily["pressure"] as! Double
        self.summary = daily["summary"] as! String
        self.temperatureMin = daily["temperatureMin"] as! Double
        self.temperatureMax = daily["temperatureMax"] as! Double
        self.time = daily["time"] as! Double
        self.date = Date(timeIntervalSince1970: self.time)
        
    }
    
    lazy var dateFormatter: DateFormatter =  {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .full
        return formatter
    }()
    
    lazy var dateString: String =  {
        
        return self.dateFormatter.string(from: self.date)
    }()
}
