//
//  Geocoder.swift
//  Weather Test Task
//
//  Created by Alex173 on 26.04.2022.
//

import Foundation
import CoreLocation

protocol GeocoderDelegate {
    func didConvertCoordinatesToName(name: String)
    func didFailWithGeocodingError(error: Error)
}

class Geocoder {
    
    var delegate: GeocoderDelegate?
    
    func getCoordinateFrom(address: String, completion: @escaping(_ coordinate: CLLocationCoordinate2D?, _ error: Error?) -> () ) {
        CLGeocoder().geocodeAddressString(address) { completion($0?.first?.location?.coordinate, $1) }
    }
    
    func converCoordToName(lat: Double, lon: Double)  {
        let location = CLLocation(latitude: lat, longitude: lon)
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if error != nil {
                self.delegate?.didFailWithGeocodingError(error: error!)
            } else {
                if let pm = placemarks {
                    if let name = pm.first?.locality {
                        self.delegate?.didConvertCoordinatesToName(name: name)
                    }
                }
            }
        }
    }
}
