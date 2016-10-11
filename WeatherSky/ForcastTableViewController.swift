//
//  ForcastTableViewController.swift
//  WeatherSky
//
//  Created by Tony Merante on 9/23/16.
//  Copyright © 2016 Tony Merante. All rights reserved.
//

import Foundation
import UIKit

class ForcastTableViewController: UITableViewController, WillNeedForcastData, WillNeedCurrentForcastData {
    
    var forcasts: Forcasts!
    var forcast: Forcast!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if var detailViewController = segue.destination as? WillNeedCurrentForcastData {
            detailViewController.forcast = self.forcast
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView.reloadData()
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.forcasts.daily.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
   		self.forcast = self.forcasts.daily[indexPath.row]
        self.performSegue(withIdentifier: "dailyForcastSegue", sender: self)
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "forcastCell",
                                                 for: indexPath) as! ForcastTableViewCell
        
        
        var forcast = self.forcasts.daily[indexPath.row]
        cell.temperatureLabel.text = String(forcast.temperatureMax)
        cell.dateLabel.text = forcast.dateString
        
        return cell
    }
    
    
}
