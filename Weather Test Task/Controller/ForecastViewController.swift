//
//  ViewController.swift
//  Weather Test Task
//
//  Created by Alex173 on 15.04.2022.
//


import UIKit
import CoreLocation
import ViewAnimator




class ForecastViewController: UIViewController {
    
    @IBOutlet weak var currentWeatherView: UIView!
    @IBOutlet weak var locationIconImage: UIImageView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currentWeatherImage: UIImageView!
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var todayDateLabel: UILabel!
    @IBOutlet weak var currentMinMaxTempLabel: UILabel!
    @IBOutlet weak var currentAverageHumidityLabel: UILabel!
    @IBOutlet weak var currentWindSpeedAndDirLabel: UILabel!
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    
    @IBOutlet weak var currentTempView: UIView!
    @IBOutlet weak var currentHumidityView: UIView!
    @IBOutlet weak var currentWindView: UIView!
    
    @IBOutlet weak var currentWindDirectionImage: UIImageView!
    
    var webService = WebService()
    var weatherRequestSource: WeatherRequestSource = .byCurrentLocation(lat: nil, lon: nil)
    let locationManager = CLLocationManager()
    var currentLatitude: Double?
    var currentLongitude: Double?
    let rightSlideAnimation = AnimationType.from(direction: .right, offset: 100)
    let leftSlideAnimation = AnimationType.from(direction: .left, offset: 100)
    let topSlideAnimation = AnimationType.from(direction: .bottom, offset: 200)
    
    var cityData: CityData?
    let weatherModel = WeatherModel()
    var weatherData: WeatherData? {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.tableView.reloadData()
                self.animateViews()
            }
        }
    }
    
    enum WeatherRequestSource {
        case byCurrentLocation(lat: Double?, lon: Double?)
        case fromMapView(lat: Double?, lon: Double?)
        case fromSearchView(city: String?)
    }
    enum Segues: String {
        case forecastToSearch = "forecastToSearch"
        case forecastToMap = "forecastToMap"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        webService.delegate = self
        chooseWeatherRequest()
    }
    
    private func chooseWeatherRequest() {
        switch weatherRequestSource {
        case .byCurrentLocation:
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
        case .fromMapView(lat: let lat, lon: let lon):
            getWeatherByCoordinates(lat: lat!, lon: lon!)
        case .fromSearchView(city: let city):
            if let selectedCity = city {
                getCoordByCityName(city: selectedCity)
            }
        }
    }
    
    private func animateViews(){
        UIView.animate(views: [cityNameLabel, locationIconImage, todayDateLabel, currentWeatherImage], animations: [leftSlideAnimation])
        UIView.animate(views: [searchButton, mapButton, currentTempView, currentHumidityView, currentWindView], animations: [rightSlideAnimation])
        UIView.animate(views: collectionView.subviews, animations: [rightSlideAnimation])
        UIView.animate(views: tableView.visibleCells, animations: [rightSlideAnimation])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.forecastToMap.rawValue {
            let destinationVC = segue.destination as? MapViewController
            destinationVC?.delegate = self
        } else if segue.identifier == Segues.forecastToSearch.rawValue {
            let destinationVC = segue.destination as? SearchViewController
            destinationVC?.delegate = self
        }
    }
    
    //MARK: - UIButtons' Methods

    @IBAction func searchButtonPressed(_ sender: UIButton) {
//        performSegue(withIdentifier: Segues.forecastToSearch.rawValue, sender: self)
    }

    @IBAction func mapButtonPressed(_ sender: UIButton) {
//       performSegue(withIdentifier: Segues.forecastToMap.rawValue, sender: self)
    }
}


// MARK: - CLLocationManagerDelegate Methods

extension ForecastViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Location got updated")
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            currentLatitude = location.coordinate.latitude
            currentLongitude = location.coordinate.longitude
            getWeatherByCoordinates(lat: currentLatitude!, lon: currentLongitude!)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        presentFailureAlert(title: "Oops! Failer to get your location!", message: "Please check geolocation options in Settings.")
        if locationManager.authorizationStatus == .denied {
            locationManager.requestWhenInUseAuthorization()
        } else if locationManager.authorizationStatus == .restricted {
            locationManager.requestWhenInUseAuthorization()
        } else if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        print(error)
    }
}



// MARK: - WebServiceDelegate Methods

extension ForecastViewController: WebServiceDelegate {
    
    
    func didGetCoordinates(_ location: CityData) {
        DispatchQueue.main.async {
            self.getWeatherByCoordinates(lat: location.coord.lat, lon: location.coord.lon)
        }
    }
    
    func didGetCityName(_ location: CityData) {
        DispatchQueue.main.async {
            self.cityData = location
            self.cityNameLabel.text = self.cityData?.name
        }
    }
    
    func didUpdateWeather(_ weather: WeatherData) {
        
        DispatchQueue.main.async { [self] in
            self.weatherData = weather
            self.currentWeatherImage.image = UIImage(named: self.weatherModel.getImageSystemName(conditionId: Int((self.weatherData?.current.weather[0].id)!)))
            let minTemp = String(Int((self.weatherData?.daily[0].temp.min)!))
            let maxTemp = String(Int((self.weatherData?.daily[0].temp.max)!))
            self.currentMinMaxTempLabel.text = minTemp + "° / " + maxTemp + "°"
            self.currentAverageHumidityLabel.text = String((self.weatherData?.daily[0].humidity)!) + "%"
            self.currentWindSpeedAndDirLabel.text = String(Int((self.weatherData?.current.wind_speed)!)) + "m/s"
            self.currentWindDirectionImage.image = UIImage(named: self.weatherModel.getWindDirectionName(windDirection: (self.weatherData?.current.wind_deg)!))
            
            let date = Date(timeIntervalSince1970: TimeInterval((weatherData?.current.dt)!))
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.full
            dateFormatter.dateFormat = "E, dd MMMM"
            dateFormatter.timeZone = .current
            let day = dateFormatter.string(from: date)
            todayDateLabel.text = day
        }
    }
    
    func didFailWithError(error: Error) {
        presentFailureAlert(title: "Oops, something went wrong!", message: error.localizedDescription)
        print("FAILED WITH ERROR: \(error)")
    }
    
// MARK: - Webservice Methods
    
    private func getWeatherByCoordinates(lat: Double, lon: Double) {
        webService.fetchWeather(latitude: lat, longitude: lon)
        webService.getCityName(latitude: lat, longitude: lon)
    }
    private func getCoordByCityName(city: String) {
        webService.getCoordinates(city: city)
    }
}
//MARK: - CollectionView Methods

extension ForecastViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 24
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hourlyCollectionViewCell", for: indexPath) as! HourlyWeatherCollectionViewCell
        
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
        collectionView.register(UINib(nibName: "HourlyWeatherCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "hourlyCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

//MARK: - TableView Methods

extension ForecastViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dailyTableViewCell", for: indexPath) as! DailyWeatherTableViewCell
        cell.dayLabel.textColor = UIColor(named: "Black")
        cell.temperatureLabel.textColor = UIColor(named: "Black")
        cell.weatherImage.tintColor = UIColor(named: "Black")
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
            cell.weatherImage.image = weatherImage?.withTintColor(.black)

        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.reloadData()
        tableView.deselectAllRows(animated: true)
        
        guard let tableViewCell = tableView.cellForRow(at: indexPath) else { return }
        let cell = tableViewCell as! DailyWeatherTableViewCell
        
        
        cell.dayLabel.textColor = UIColor(named: "LightBlue")
        cell.temperatureLabel.textColor = UIColor(named: "LightBlue")
        cell.weatherImage.tintColor = UIColor(named: "LightBlue")
        cell.backView.layer.shadowColor = UIColor.gray.cgColor
        cell.backView.layer.masksToBounds = false
        cell.backView.layer.shadowRadius = 10
        cell.backView.layer.shadowOpacity = 1.0
        
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: "DailyWeatherTableViewCell", bundle: nil), forCellReuseIdentifier: "dailyTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension UITableView {
    func deselectAllRows(animated: Bool) {
        guard let selectedRows = indexPathsForSelectedRows else { return }
        for indexPath in selectedRows { deselectRow(at: indexPath, animated: animated) }
    }
}
//MARK: - FailureAlert Methods
extension ForecastViewController {
    private func presentFailureAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: UIAlertAction.Style.default, handler: { _ in
            self.chooseWeatherRequest()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

//MARK: - ViewControllers' Delegate Methods
extension ForecastViewController: MapViewControllerDelegate {
    func didTapGetWeatherButton(lat: Double, lon: Double) {
        self.weatherRequestSource = .fromMapView(lat: lat, lon: lon)
    }
}

extension ForecastViewController: SearchViewControllerDelegate {
    func didTapSearchToForecastButton(city: String) {
        self.weatherRequestSource = .fromSearchView(city: city)
    }
}
