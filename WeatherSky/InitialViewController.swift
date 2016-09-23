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
import AddressBook
import MapKit
import Contacts

class InitialViewController: UIViewController, CLLocationManagerDelegate,
WillNeedForcastData {
    
    // MARK: Properties
    var forcasts: Forcasts!
    var locationManager: CLLocationManager!
    lazy var weatherService = {
        return WeatherService()
    }()
    
    // MARK: ---
    
    
    // MARK: View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        
        self.locationManager.requestWhenInUseAuthorization()
        
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if var detailViewController = segue.destination as? WillNeedForcastData {
            detailViewController.forcasts = self.forcasts
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
        
        guard let lat = WeatherLocationManager.sharedSingleton.latitude, let long = WeatherLocationManager.sharedSingleton.longitude else {
            return
        }
        
        self.weatherService.fetchWeatherData(byLatitude: lat, andLongitude: long) { result in
            
         result.value.forcasts
            DispatchQueue.main.async {
                self.forcasts = result.value.forcasts
                self.performSegue(withIdentifier: "forcastDetailsSegue", sender: self)
            }
        }
        
    }
    
    @IBOutlet weak var zipCodeTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
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





//
//  Forcast.swift
//  ImprovingU-Beginning-iOS-Swift
//
//  Created by Tony Merante on 9/9/16.
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


protocol WillNeedForcastData {
    var forcasts: Forcasts! { get set }
}



