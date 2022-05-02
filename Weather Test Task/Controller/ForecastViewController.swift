//
//  ViewController.swift
//  Weather Test Task
//
//  Created by Alex173 on 15.04.2022.
//


import UIKit
import CoreLocation
import ViewAnimator
import Combine
import NVActivityIndicatorView

class ForecastViewController: UIViewController {
    
    private enum Constants {
        static let forecastToSearch = "forecastToSearch"
        static let forecastToMap = "forecastToMap"
        static let uiAlertActionTitleRetry = "Retry"
        static let uiAlertActionTitleCancel = "Cancel"
        static let uiAlertActionTitleUseWithoutLocation = "Use without location"
        static let uiAlertActionTitleOpenSettings = "Open Settings"
        static let alertFailedToGetLocationTitle = "Oops! Failed to get your location!"
        static let alertFailedToGetWeatherByCityTitle = "Oops! Failed to get Weather by City Name: "
        static let alertFailedToGetLocationMessage = "Please try again or use app without location features"
        static let alertSomethingWentWrongTitle = "Oops, something went wrong!"
        static let alertSomethingWentWrongError = "Unable to create URL"
        static let alertFailedWithGeocodingTitle = "Oops! Failed to Geocode your Data!"
        static let alertFailedWithGeocodingError = "No location name found while geocoding Data"
        static let collectionViewCellReuseIdentifier = "hourlyCollectionViewCell"
        static let collectionViewCellnib = "HourlyWeatherCollectionViewCell"
        static let tableViewCellReuseIdentifier = "dailyTableViewCell"
        static let tableViewCellnib = "DailyWeatherTableViewCell"
        static let unknownCity = "Unknown City"
        static let collectionViewNumberOfItemsInSection = 24
        static let tableViewNumberOfRowsInSection = 7
        static let defaultLatitude = 50.4
        static let defaultLongitude = 30.5
    }
    
    @IBOutlet private weak var currentLocationButton: UIButton!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var currentWeatherImage: UIImageView!
    
    @IBOutlet private weak var cityNameLabel: UILabel!
    @IBOutlet private weak var todayDateLabel: UILabel!
    @IBOutlet private weak var currentMinMaxTempLabel: UILabel!
    @IBOutlet private weak var currentAverageHumidityLabel: UILabel!
    @IBOutlet private weak var currentWindSpeedAndDirLabel: UILabel!
    @IBOutlet private weak var currentWindDirectionImage: UIImageView!
    
    @IBOutlet private weak var searchButton: UIButton!
    @IBOutlet private weak var mapButton: UIButton!
    
    @IBOutlet private weak var currentWeatherView: UIView!
    @IBOutlet private weak var currentTempView: UIView!
    @IBOutlet private weak var currentHumidityView: UIView!
    @IBOutlet private weak var currentWindView: UIView!
    
    private let loadingView = LoadingView()
    private var cancellable: AnyCancellable?
    private var cancellable2: AnyCancellable?
    private var webService = WebService()
    private var geoCoder = Geocoder()
    private var weatherRequestSource: WeatherRequestSource = .byCurrentLocation(lat: nil, lon: nil)
    private let locationManager = CLLocationManager()
    private var tableViewSelectedCell: Int?
    private var currentLatitude: Double?
    private var currentLongitude: Double?
    private var currentCityName: String? {
        didSet {
            DispatchQueue.main.async {
                self.cityNameLabel.text = self.currentCityName
            }
        }
    }
    
    private let rightSlideAnimation = AnimationType.from(direction: .right, offset: 100)
    private let leftSlideAnimation = AnimationType.from(direction: .left, offset: 100)
    private let topSlideAnimation = AnimationType.from(direction: .bottom, offset: 200)
    
    private let weatherModel = WeatherModel()
    private var weatherData: WeatherData?
    
    private enum WeatherRequestSource {
        case byCurrentLocation(lat: Double?, lon: Double?)
        case fromMapView(lat: Double?, lon: Double?)
        case fromSearchView(lat: Double?, lon: Double?, name: String?)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webService.delegate = self
        geoCoder.delegate = self
        setupCollectionView()
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        loadingView.createLoadingView(parentView: self.view)
        chooseWeatherRequestSource()
    }
    
    private func chooseWeatherRequestSource() {
        switch weatherRequestSource {
        case .byCurrentLocation:
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
        case .fromMapView(lat: let lat, lon: let lon):
            if let latitude = lat, let longitude = lon {
                convertCoordinateToCityName(lat: latitude, lon: longitude)
                getWeatherByCoordinates(lat: latitude, lon: longitude)
            }
        case .fromSearchView(lat: let lat, lon: let lon, name: let name):
            if let latitude = lat, let longitude = lon, let placeName = name {
                self.currentCityName = placeName
                getWeatherByCoordinates(lat: latitude, lon: longitude)
            }
        }
    }
    
    private func animateViews(){
        UIView.animate(views: [cityNameLabel, currentLocationButton, todayDateLabel, currentWeatherImage], animations: [leftSlideAnimation])
        UIView.animate(views: [searchButton, mapButton, currentTempView, currentHumidityView, currentWindView], animations: [rightSlideAnimation])
        UIView.animate(views: collectionView.subviews, animations: [rightSlideAnimation])
        UIView.animate(views: tableView.visibleCells, animations: [rightSlideAnimation])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.forecastToMap {
            let destinationVC = segue.destination as? MapViewController
            destinationVC?.delegate = self
        } else if segue.identifier == Constants.forecastToSearch {
            let destinationVC = segue.destination as? SearchViewController
            destinationVC?.delegate = self
        }
    }
    
    //MARK: - UIButtons' Methods
    
    @IBAction private func searchButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction private func mapButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction private func currentLocationButtonPressed(_ sender: UIButton) {
        locationManager.requestLocation()
        loadingView.showLoadingView()
    }
}


// MARK: - CLLocationManagerDelegate Methods

extension ForecastViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            self.presentFailureAlert(title: Constants.alertFailedToGetLocationTitle, message: Constants.alertFailedToGetLocationMessage)
            return
        }
        locationManager.stopUpdatingLocation()
        currentLatitude = location.coordinate.latitude
        currentLongitude = location.coordinate.longitude
        guard let lat = currentLatitude, let lon = currentLongitude else {
            self.presentFailureAlert(title: Constants.alertFailedToGetLocationTitle, message: Constants.alertFailedToGetLocationMessage)
            return
        }
        convertCoordinateToCityName(lat: lat, lon: lon)
        getWeatherByCoordinates(lat: lat, lon: lon)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
        case .denied, .restricted:
            presentGoToSettingsAlert(title: Constants.alertFailedToGetLocationTitle, message: Constants.alertFailedToGetLocationMessage)
        case .authorizedAlways, .authorizedWhenInUse:
            presentGoToSettingsAlert(title: Constants.alertFailedToGetLocationTitle, message: Constants.alertFailedToGetLocationMessage)
        @unknown default:
            break
        }
    }
}

// MARK: - WebServiceDelegate Methods

extension ForecastViewController: WebServiceDelegate {
    
    
    func didUpdateWeather(_ weather: WeatherData) {
        
        DispatchQueue.main.async { [weak self] in
            if let weatherID = self?.weatherData?.current.weather[0].id {
                self?.currentWeatherImage.image = UIImage(named: self?.weatherModel.getImageSystemName(conditionId: Int(weatherID)) ?? "")
            }
            if let minTemp = self?.weatherData?.daily[0].temp.min, let maxTemp = self?.weatherData?.daily[0].temp.max {
                self?.currentMinMaxTempLabel.text = String(Int(minTemp)) + "° / " + String(Int(maxTemp)) + "°"
            }
            if let humidity = self?.weatherData?.daily[0].humidity {
                self?.currentAverageHumidityLabel.text = String(humidity) + "%"
            }
            if let windSpeed = self?.weatherData?.current.wind_speed {
                self?.currentWindSpeedAndDirLabel.text = String(Int(windSpeed)) + "m/s"
            }
            if let windDirection = self?.weatherData?.current.wind_deg {
                self?.currentWindDirectionImage.image = UIImage(named: self?.weatherModel.getWindDirectionName(windDirection: windDirection) ?? "")
            }
            
            if let dt = self?.weatherData?.current.dt {
                let date = Date(timeIntervalSince1970: TimeInterval(dt))
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = DateFormatter.Style.full
                dateFormatter.dateFormat = "E, dd MMMM"
                dateFormatter.timeZone = .current
                let day = dateFormatter.string(from: date)
                self?.todayDateLabel.text = day
            }
            
            if self?.currentCityName == nil {
                self?.cityNameLabel.text = Constants.unknownCity
            }
        }
    }
    
    func didFailWithError(error: Error?) {
        presentFailureAlert(title: Constants.alertSomethingWentWrongTitle, message: error?.localizedDescription ?? Constants.alertSomethingWentWrongError)
    }
    
    // MARK: - Webservice Methods
    
    private func getWeatherByCoordinates(lat: Double, lon: Double) {
        self.cancellable = self.webService.fetchCombineWeather(latitude: lat, longitude: lon)
            .catch { _ in Empty()}
            .map {$0.self}
            .sink { [weak self] weatherData in
                self?.weatherData = weatherData
                DispatchQueue.main.async {
                    self?.loadingView.hideLoadingView()
                    self?.didUpdateWeather(weatherData)
                    self?.collectionView.reloadData()
                    self?.tableView.reloadData()
                    self?.animateViews()
                }
            }
    }
    
    private func convertCoordinateToCityName(lat: Double, lon: Double) {
        self.geoCoder.converCoordToName(lat: lat, lon: lon)
    }
}

//MARK: - GeocoderDelegate Methods

extension ForecastViewController: GeocoderDelegate {
    func didFailWithGeocodingError(error: Error?) {
        presentFailureAlert(title: Constants.alertFailedWithGeocodingTitle, message: error?.localizedDescription ?? Constants.alertFailedWithGeocodingError )
    }
    
    func didConvertCoordinatesToName(name: String) {
        self.currentCityName = name
    }
}
//MARK: - CollectionView Methods

extension ForecastViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Constants.collectionViewNumberOfItemsInSection
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.collectionViewCellReuseIdentifier, for: indexPath) as? HourlyWeatherCollectionViewCell else { return UICollectionViewCell() }
        
        if let _weatherData = weatherData {
            let hourlyData = _weatherData.hourly[indexPath.item]
            
            let temperature = String(Int(hourlyData.temp))
            let weatherImage = UIImage(named: weatherModel.getImageSystemName(conditionId: hourlyData.weather[0].id))
            
            let date = Date(timeIntervalSince1970: TimeInterval(hourlyData.dt))
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.full
            dateFormatter.dateFormat = "HH"
            dateFormatter.timeZone = .current
            let hour = dateFormatter.string(from: date)
            
            cell.hourLabel.text = hour
            cell.temperatureLabel.text = temperature + "°"
            cell.weatherImage.image = weatherImage
            
        }
        return cell
    }
    
    private func setupCollectionView() {
        collectionView.register(UINib(nibName: Constants.collectionViewCellnib, bundle: nil), forCellWithReuseIdentifier: Constants.collectionViewCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

//MARK: - TableView Methods

extension ForecastViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.tableViewNumberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.tableViewCellReuseIdentifier, for: indexPath) as? DailyWeatherTableViewCell else { return UITableViewCell() }
        if let _weatherData = weatherData {
            let dailyData = _weatherData.daily[indexPath.row]
            
            let minMaxTemperature = String(Int(dailyData.temp.min)) + "° / " + String(Int(dailyData.temp.max)) + "°"
            let weatherImage = UIImage(named: weatherModel.getImageSystemName(conditionId: dailyData.weather[0].id))
            
            let date = Date(timeIntervalSince1970: TimeInterval(dailyData.dt))
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.full
            dateFormatter.dateFormat = "E"
            dateFormatter.timeZone = .current
            let day = dateFormatter.string(from: date)
            
            cell.dayLabel.text = day
            cell.temperatureLabel.text = minMaxTemperature
            cell.weatherImage.image = weatherImage?.withTintColor(UIColor.black!)
            cell.setSelected(dailyData.isSelected ?? false, animated: true)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? DailyWeatherTableViewCell else { return }
        cell.setSelected(false, animated: true)
        
        for (index, _) in (weatherData?.daily ?? []).enumerated() {
            weatherData?.daily[index].isSelected = false
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? DailyWeatherTableViewCell else { return }
        cell.setSelected(true, animated: true)
        
        for (index, _) in (weatherData?.daily ?? []).enumerated() {
            weatherData?.daily[index].isSelected = false
        }
        
        guard weatherData?.daily[safe: indexPath.row] != nil else { return }
        weatherData?.daily[indexPath.row].isSelected = true
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let _weatherData = weatherData {
            let dailyData = _weatherData.daily[indexPath.row]
            cell.setSelected(dailyData.isSelected ?? false, animated: true)
        }
        guard let cell = tableView.cellForRow(at: indexPath) as? DailyWeatherTableViewCell else { return }
        
        if let _weatherData = weatherData {
            let dailyData = _weatherData.daily[indexPath.row]
            cell.contentView.layer.masksToBounds = true
            cell.setSelected(dailyData.isSelected ?? false, animated: true)
        }
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: Constants.tableViewCellnib, bundle: nil), forCellReuseIdentifier: Constants.tableViewCellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
}


//MARK: - FailureAlert Methods
extension ForecastViewController {
    private func presentFailureAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Constants.uiAlertActionTitleRetry, style: UIAlertAction.Style.default, handler: { _ in
            switch self.weatherRequestSource {
            case .byCurrentLocation:
                self.locationManager.requestLocation()
            case .fromMapView:
                self.performSegue(withIdentifier: Constants.forecastToMap, sender: self)
            case .fromSearchView:
                self.performSegue(withIdentifier: Constants.forecastToSearch, sender: self)
            }
        }))
        alert.addAction(UIAlertAction(title: Constants.uiAlertActionTitleCancel, style: UIAlertAction.Style.default, handler: { _ in
            self.getWeatherByCoordinates(lat: Constants.defaultLatitude, lon: Constants.defaultLongitude )
            self.convertCoordinateToCityName(lat: Constants.defaultLatitude, lon: Constants.defaultLongitude)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func presentGoToSettingsAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Constants.uiAlertActionTitleOpenSettings, style: UIAlertAction.Style.default, handler: { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { _ in
                    self.chooseWeatherRequestSource()
                })
            }
        }))
        alert.addAction(UIAlertAction(title: Constants.uiAlertActionTitleUseWithoutLocation, style: UIAlertAction.Style.default, handler: { _ in
            self.getWeatherByCoordinates(lat: Constants.defaultLatitude, lon: Constants.defaultLongitude )
            self.convertCoordinateToCityName(lat: Constants.defaultLatitude, lon: Constants.defaultLongitude)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}

//MARK: - ViewControllers' Delegate Methods
extension ForecastViewController: MapViewControllerDelegate {
    func didTapReturnButtonMapVC() {
        self.weatherRequestSource = .byCurrentLocation(lat: currentLatitude, lon: currentLongitude)
    }
    
    func didTapGetWeatherButton(lat: Double, lon: Double) {
        self.weatherRequestSource = .fromMapView(lat: lat, lon: lon)
    }
}

extension ForecastViewController: SearchViewControllerDelegate {
    func didTapReturnButtonSearchVC() {
        self.weatherRequestSource = .byCurrentLocation(lat: currentLatitude, lon: currentLongitude)
    }
    
    func didTapSearchToForecastButton(lat: Double, lon: Double, name: String) {
        self.weatherRequestSource = .fromSearchView(lat: lat, lon: lon, name: name)
    }
    
}

