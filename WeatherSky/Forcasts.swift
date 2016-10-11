//
//  Forcasts.swift
//  WeatherSky
//
//  Created by Tony Merante on 10/4/16.
//  Copyright © 2016 Tony Merante. All rights reserved.
//

import Foundation
struct Forcasts {
    
    var today: Forcast!
    var daily: [Forcast]!
    
    init(json: Dictionary<String, AnyObject>) {
        
        if let currently = json["currently"] as? Dictionary<String, AnyObject>  {
            self.today = Forcast(currently: currently)
        }
        
        if let daily = json["daily"] as? Dictionary<String, AnyObject> {
            if let data = daily["data"]  {
                if let forcasts = data as? Array<AnyObject> {
                    self.daily = forcasts.map { d in
                        if let daily = d as? Dictionary<String, AnyObject> {
                            let day = Forcast(daily: daily)
                            return day
                        }
                        
                        return Forcast()
                    }
                    
                }
            }
        }
        
    }
}
