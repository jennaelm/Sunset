//
//  SunsetViewController.swift
//  Sunset
//
//  Created by Jenna Miller on 6/26/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//

import UIKit
import CoreLocation

class SunsetViewController: UIViewController, CLLocationManagerDelegate, DataManagerDelegate {

    @IBOutlet weak var timeLabel: UILabel!
    
    let locationManager = CLLocationManager()
    let dataManager = DataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Go be free
        
        self.dataManager.delegate = self
        self.locationManager.delegate = self
        
        getLocationPermission()
    }
    
// Location Services
    
    func getLocationPermission() {
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.startUpdatingLocation()
        } else {
            getLocationPermission()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var userLocation = CLLocation()
        
        if locations.count > 0 {
            userLocation = locations[0]
            locationManager.stopUpdatingLocation()
            let lati = "\(userLocation.coordinate.latitude)" as String!
            let longi = "\(userLocation.coordinate.longitude)" as String!
            self.dataManager.getSunsetTime(lati, longitude: longi)
        }
    }
    
// Data Manager Delegate
    
    func sunsetUpdated(time: String) {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.timeLabel.text = time
        }
    }

}
