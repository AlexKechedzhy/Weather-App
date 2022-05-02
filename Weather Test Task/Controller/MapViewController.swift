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
    
    private enum Constants {
        static let uiAlertActionTitleOK = "OK"
        static let uiAlertActionTitleOpenSetting = "Open Settings"
        static let uiAlertActionTitleCancel = "Cancel"
        static let alertSomethingWentWrongTitle = "Oops! Failed to get your location!"
        static let alertGoToSettingsTitle = "Seems like your location is disabled"
        static let alertGoToSettingsMessage = "Please allow Weather app to use your location via Settings"
        static let regionLatitudinalMeters = 100000
        static let regionLongitudinalMeters = 100000
    }
    
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var backButtonView: UIView!
    @IBOutlet private weak var getWeatherButton: UIButton!
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
        getWeatherButton.layer.cornerRadius = 20
        getWeatherButton.backgroundColor = UIColor.darkBlue
        getWeatherButton.isHidden = true
        backButtonView.layer.cornerRadius = 25
    }
    
    private func centerScreen(location: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 100000, longitudinalMeters: 100000)
        mapView.setRegion(region, animated: true)
    }
    
    //MARK: - UIButton's Methods
    
    @IBAction func getWeatherButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        if let lat = selectedLatitude, let lon = selectedLongitude {
            delegate?.didTapGetWeatherButton(lat: lat, lon: lon)
        }
    }
    
    @IBAction func backToForecastButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
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
        if UserDefaultsModel.highResolutionPlanets == false {
            UserDefaultsModel.highResolutionPlanets = true
            presentGoToSettingsAlert(title: Constants.alertGoToSettingsTitle, message: Constants.alertGoToSettingsMessage)
        } else {
            presentFailureAlert(title: Constants.alertSomethingWentWrongTitle, message: error.localizedDescription)
        }
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

//MARK: - FailureAlert Methods

extension MapViewController {
    private func presentFailureAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Constants.uiAlertActionTitleOK, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func presentGoToSettingsAlert(title: String, message: String)  {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Constants.uiAlertActionTitleOpenSetting, style: UIAlertAction.Style.default, handler: { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { _ in
                    self.locationManager.requestLocation() // This line requres update. I need to request location when the app resigns active.
                })
            }
        }))
        alert.addAction(UIAlertAction(title: Constants.uiAlertActionTitleCancel, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
