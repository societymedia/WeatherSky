//
//  WillNeedForcastData.swift
//  WeatherSky
//
//  Created by Tony Merante on 10/4/16.
//  Copyright © 2016 Tony Merante. All rights reserved.
//

import Foundation

protocol WillNeedForcastData {
    var forcasts: Forcasts! { get set }
}

protocol WillNeedCurrentForcastData {
    var forcast:Forcast! { get set}
}
