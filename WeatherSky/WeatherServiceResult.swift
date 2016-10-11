//
//  WeatherServiceResult.swift
//  WeatherSky
//
//  Created by Tony Merante on 10/4/16.
//  Copyright © 2016 Tony Merante. All rights reserved.
//

import Foundation
import CoreLocation

enum WeatherServiceResult: Error {
    case addressLocated(CLPlacemark)
    case noAddress
    case success(Forcasts!)
    case invalidJSON
    case error(Error)
    
    var value: ValueResult  {
        switch self {
        case .addressLocated(let pm):
            return ValueResult(placemark: pm)
        case .success(let fc):
            return ValueResult(forcasts: fc)
        default:
            return ValueResult()
        }
    }
}
