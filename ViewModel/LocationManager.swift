//
//  LocationManager.swift
//  CobainMaps
//
//  Created by Leee on 18/07/23.
//

import Foundation
import CoreLocation

class LocationManager : NSObject ,CLLocationManagerDelegate{
    static let shared = LocationManager()
    var locationManager = CLLocationManager()
    var heading : CLHeading?
    var location : CLLocation?
    override init(){
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        switch status{
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        default:
            break
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let newLocation = locations.last{
            location = newLocation
        }
    }
    
}
