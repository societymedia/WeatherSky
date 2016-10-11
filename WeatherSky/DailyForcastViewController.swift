//
//  DailyForcastViewController.swift
//  WeatherSky
//
//  Created by Tony Merante on 9/23/16.
//  Copyright © 2016 Tony Merante. All rights reserved.
//

import Foundation
import UIKit

class DailyForcastViewController: UIViewController, WillNeedCurrentForcastData {
    var forcast: Forcast!

    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    override func viewDidLoad() {
        
    	self.dateLabel.text = self.forcast.dateString
        self.temperatureLabel.text = String(self.forcast.temperature)
    }
    
    
}
