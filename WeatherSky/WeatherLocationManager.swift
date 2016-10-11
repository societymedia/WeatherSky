//
//  WeatherLocationManager.swift
//  WeatherSky
//
//  Created by Tony Merante on 10/4/16.
//  Copyright © 2016 Tony Merante. All rights reserved.
//

import Foundation
import CoreLocation
import AddressBook
import MapKit
import Contacts

class WeatherLocationManager {
    
    var latitude: Double?
    var longitude: Double?
    var zipCode: Int?
    
    static let sharedSingleton = WeatherLocationManager()
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(location: CLLocation) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
    }
    init(zipCode: Int) {
        self.zipCode = zipCode
    }
    init(){}
}
