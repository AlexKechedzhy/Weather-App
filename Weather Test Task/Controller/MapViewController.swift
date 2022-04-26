//
//  MapViewController.swift
//  Weather Test Task
//
//  Created by Alex173 on 20.04.2022.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate: AnyObject {
    func didTapGetWeatherButton(lat: Double, lon: Double)
}

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var backButtonView: UIView!
    @IBOutlet weak var getWeatherButton: UIButton!
    private let locationManager = CLLocationManager()
    private let pin = MKPointAnnotation()
    private var selectedLatitude: Double?
    private var selectedLongitude: Double?
    weak var delegate: MapViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        setupLocationManager()
        setupGestureRecognizer()
        
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
    
    private func prepareUI() {
        getWeatherButton.isHidden = true
        backButtonView.layer.cornerRadius = 25
    }
    
    func centerScreen(location: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 100000, longitudinalMeters: 100000)
        mapView.setRegion(region, animated: true)
    }
    
    //MARK: - UIButton's Methods
    
    @IBAction func getWeatherButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        if let lat = selectedLatitude, let lon = selectedLongitude {
            delegate?.didTapGetWeatherButton(lat: lat, lon: lon)
        }
        self.dismiss(animated: true)
    }
    
    @IBAction func backToForecastButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true)
    }
}


//MARK: - CLLocationManagerDelegate Methods
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
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
            pin.coordinate = locationCoordinate
            getWeatherButton.isHidden = false
            selectedLatitude = locationCoordinate.latitude
            selectedLongitude = locationCoordinate.longitude
        }
    }
}
