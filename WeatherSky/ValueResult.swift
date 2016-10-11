//
//  ValueResult.swift
//  WeatherSky
//
//  Created by Tony Merante on 10/4/16.
//  Copyright © 2016 Tony Merante. All rights reserved.
//

import Foundation
import CoreLocation

struct ValueResult {
    var placeMark:CLPlacemark?
    var forcasts:Forcasts?
    
    init(placemark: CLPlacemark) {
        self.placeMark = placemark
    }
    
    init(forcasts: Forcasts) {
        self.forcasts = forcasts
    }
    
    init() {}
    
}
