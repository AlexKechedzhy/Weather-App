//
//  MapViewController.swift
//  Weather Test Task
//
//  Created by Alex173 on 20.04.2022.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var getWeatherButton: UIButton!
    let locationManager = CLLocationManager()
    let pin = MKPointAnnotation()
    var selectedLatitude: Double?
    var selectedLongitude: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        setupGestureRecognizer()
        getWeatherButton.isHidden = true
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    private func setupGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(
            target: self, action: #selector(MapViewController.handleTapGesture(sender:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        self.mapView.addGestureRecognizer(tapGesture)
        mapView.addAnnotation(pin)
    }
    
    
    
    func centerScreen(location: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 100000, longitudinalMeters: 100000)
        mapView.setRegion(region, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        if segue.identifier == "mapToForecast" {
            let destinationVC = segue.destination as! ForecastViewController
            destinationVC.weatherRequestSource = .fromMapView
            destinationVC.selectedMapLatitude = selectedLatitude
            destinationVC.selectedMapLongitude = selectedLongitude
        }
    }
    
    //MARK: - UIButton's Methods
    
    @IBAction func getWeatherButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "mapToForecast", sender: self)
    }
}


//MARK: - CLLocationManagerDelegate Methods
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last?.coordinate {
            locationManager.stopUpdatingLocation()
            centerScreen(location: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

extension MapViewController: UIGestureRecognizerDelegate {
    @objc func handleTapGesture(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let touchLocation = sender.location(in: mapView)
            let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
            print("Tapped at coordinates: \(locationCoordinate.latitude) - \(locationCoordinate.longitude)")
            pin.coordinate = locationCoordinate
            getWeatherButton.isHidden = false
            selectedLatitude = locationCoordinate.latitude
            selectedLongitude = locationCoordinate.longitude
        }
    }
}
