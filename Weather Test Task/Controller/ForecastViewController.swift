//
//  ViewController.swift
//  Weather Test Task
//
//  Created by Alex173 on 15.04.2022.
//


import UIKit
import CoreLocation


class ForecastViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currentWeatherImage: UIImageView!
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var currentMinMaxTempLabel: UILabel!
    @IBOutlet weak var currentAverageHumidityLabel: UILabel!
    @IBOutlet weak var currentWindSpeedAndDirLabel: UILabel!
    @IBOutlet weak var currentWindDirectionImage: UIImageView!
    
    
    var webService = WebService()
    let locationManager = CLLocationManager()
    var currentLatitude: Double?
    var currentLongitude: Double?
    var selectedMapLatitude: Double?
    var selectedMapLongitude: Double?
    
    var weatherData: WeatherData? {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.tableView.reloadData()
            }
        }
    }
    var cityData: CityData?
    let weatherModel = WeatherModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        setupCollectionView()
        setupTableView()
        webService.delegate = self
        
        if selectedMapLatitude != nil && selectedMapLongitude != nil {
            getWeatherData(lat: selectedMapLatitude!, lon: selectedMapLongitude!)
        } else {
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
        }
        
    }
    
    //MARK: - UIButtons' Methods

    @IBAction func searchButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "searchViewController", sender: self)
    }
    
    @IBAction func mapButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "mapViewController", sender: self)
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
            getWeatherData(lat: currentLatitude!, lon: currentLongitude!)
            
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}



// MARK: - WebServiceDelegate Methods

extension ForecastViewController: WebServiceDelegate {
    func didUpdateLocation(_ location: CityData) {
        DispatchQueue.main.async {
            self.cityData = location
            self.cityNameLabel.text = self.cityData?.name
        }
    }
    
    func didUpdateWeather(_ weather: WeatherData) {
        
        DispatchQueue.main.async { [self] in
            self.weatherData = weather
            self.currentWeatherImage.image = UIImage(systemName: self.weatherModel.getImageSystemName(conditionId: Int((self.weatherData?.current.weather[0].id)!)))
            let minTemp = String(Int((self.weatherData?.daily[0].temp.min)!))
            let maxTemp = String(Int((self.weatherData?.daily[0].temp.max)!))
            self.currentMinMaxTempLabel.text = minTemp + "° / " + maxTemp + "°"
            self.currentAverageHumidityLabel.text = String((self.weatherData?.daily[0].humidity)!) + "%"
            self.currentWindSpeedAndDirLabel.text = String(Int((self.weatherData?.current.wind_speed)!)) + "m/s"
            self.currentWindDirectionImage.image = UIImage(systemName: self.weatherModel.getWindDirectionName(windDirection: (self.weatherData?.current.wind_deg)!))
        }
    }
    
    func didFailWithError(error: Error) {
        print("FAILED WITH ERROR: \(error)")
    }
    
// MARK: - Webservice Methods
    
    func getWeatherData(lat: Double, lon: Double) {
        webService.fetchWeather(latitude: lat, longitude: lon)
        webService.getCityName(latitude: lat, longitude: lon)
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
            let weatherImage = UIImage(systemName: weatherModel.getImageSystemName(conditionId: hourlyData.weather[0].id))
            
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
        if let _weatherData = weatherData {
            let dailyData = _weatherData.daily[indexPath.row]

            let minMaxTemperature = String(Int(dailyData.temp.min)) + "° / " + String(Int(dailyData.temp.max)) + "°"
            let weatherImage = UIImage(systemName: weatherModel.getImageSystemName(conditionId: dailyData.weather[0].id))

            let date = Date(timeIntervalSince1970: TimeInterval(dailyData.dt))
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.full
            dateFormatter.dateFormat = "E"
            dateFormatter.timeZone = .current
            let day = dateFormatter.string(from: date)

            cell.dayLabel.text = day
            cell.temperatureLabel.text = minMaxTemperature
            cell.weatherImage.image = weatherImage

        }
        return cell
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: "DailyWeatherTableViewCell", bundle: nil), forCellReuseIdentifier: "dailyTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
}


