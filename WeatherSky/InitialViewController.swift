//
//  ViewController.swift
//  WeatherSky
//
//  Created by Tony Merante on 9/20/16.
//  Copyright © 2016 Tony Merante. All rights reserved.
//
import Foundation
import UIKit
import CoreLocation
import MapKit

class InitialViewController: UIViewController, CLLocationManagerDelegate,
WillNeedForcastData, WillNeedCurrentForcastData {
    
    // MARK: Properties
    var forcasts: Forcasts!
    var forcast: Forcast!
    
    var locationManager: CLLocationManager!
    lazy var weatherService: WeatherService = WeatherService()
    // MARK: ---
    
    
    // MARK: View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        
        self.locationManager.requestWhenInUseAuthorization()
        
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if self.forcast == nil || self.forcasts == nil {
            return false
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if var detailViewController = segue.destination as? WillNeedForcastData {
            detailViewController.forcasts = self.forcasts
        }
        
        if var detailViewController = segue.destination as? WillNeedCurrentForcastData {
            detailViewController.forcast = self.forcast
        }
    }
    // MARK: ---
    
    // MARK: Location Manager Delegates
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            self.locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       
        guard let newLocation = locations.last else {
            return
        }
        
        self.weatherService.transformToAddress(fromLocation: newLocation) { result in
            
            if let zipCode = result.value.placeMark?.addressDictionary?["ZIP"] as? String  {
                WeatherLocationManager.sharedSingleton.zipCode = Int(zipCode)
                self.zipCodeTextField.text = zipCode
            }
            
            self.weatherService.fetchWeatherData(byLatitude: newLocation.coordinate.latitude, andLongitude: newLocation.coordinate.longitude) { result in
                DispatchQueue.main.async {
                    self.forcasts = result.value.forcasts
                    self.forcast = result.value.forcasts?.today
                }
            }
            
            WeatherLocationManager.sharedSingleton.latitude = newLocation.coordinate.latitude
            WeatherLocationManager.sharedSingleton.longitude = newLocation.coordinate.longitude
            
            
            var mapRegion = MKCoordinateRegion()
            mapRegion.center = newLocation.coordinate
            mapRegion.span.latitudeDelta = 0.1;
            mapRegion.span.longitudeDelta = 0.1;
            
            self.mapView.setRegion(mapRegion, animated: true)
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("An error has occurred getting location")
        
    }
    
    // MARK: ---
    
    
    // MARK: Outlets and Actions
    @IBAction func forcastButtonTapped(_ sender: AnyObject) {
        
        guard let _ = WeatherLocationManager.sharedSingleton.latitude, let _ = WeatherLocationManager.sharedSingleton.longitude else {
            print("Weather Location Manager does not have latitude or Longitude set")
            return
            
        }
        
       // self.performSegue(withIdentifier: "forcastsSegue", sender: self)
    	self.performSegue(withIdentifier: "forcastDetailsSegue", sender: self)
    }
    
    @IBOutlet weak var zipCodeTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}















