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
    func didFailWithGeocodingError(error: Error?)
}

class Geocoder {
    
    var delegate: GeocoderDelegate?
    
    func converCoordToName(lat: Double, lon: Double)  {
        let location = CLLocation(latitude: lat, longitude: lon)
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if error != nil {
                self.delegate?.didFailWithGeocodingError(error: error)
            } else {
                guard let pm = placemarks else {
                    self.delegate?.didFailWithGeocodingError(error: error)
                    return
                }
                guard let name = pm.first?.locality else {
                    self.delegate?.didFailWithGeocodingError(error: error)
                    return
                }
                self.delegate?.didConvertCoordinatesToName(name: name)
            }
        }
    }
}
