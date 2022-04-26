//
//  Webservice.swift
//  Weather Test Task
//
//  Created by Alex173 on 15.04.2022.
//

import Foundation

protocol WebServiceDelegate {
    func didUpdateWeather(_ weather: WeatherData)
    func didFailWithError(error: Error)
    func didGetCityName(_ location: CityData)
    func didGetCoordinates(_ location: CityData)
}


struct WebService {
    
    var delegate: WebServiceDelegate?
    
    enum Constants: String {
        case apiKey = "144ae1233d3463be4dc6dd11edb813c8"
        case weatherURL = "https://api.openweathermap.org/data/2.5/onecall?exclude=alerts,minutely&units=metric"
        case cityURL = "https://api.openweathermap.org/data/2.5/weather?"
    }
    
    enum Caller {
        case getCityName
        case getCoordinates
        case fetchWeather
    }
    
    func getCityName(latitude: Double, longitude: Double) {
        let urlString = "\(Constants.cityURL.rawValue)lat=\(String(format:"%.3f", latitude))&lon=\(String(format:"%.3f", longitude))&appid=\(Constants.apiKey.rawValue)"
        print(urlString)
        performRequest(with: urlString, for: .getCityName)
    }
    
    func getCoordinates(city: String) {
        let urlString = "\(Constants.cityURL.rawValue)q=\(city)&appid=\(Constants.apiKey.rawValue)&units=metric"
        print(urlString)
        performRequest(with: urlString, for: .getCoordinates)
    }
    
    func fetchWeather (latitude: Double, longitude: Double) {
        let urlString = "\(Constants.weatherURL.rawValue)&lat=\(String(format:"%.3f", latitude))&lon=\(String(format:"%.3f", longitude))&appid=\(Constants.apiKey.rawValue)"
        print(urlString)
        performRequest(with: urlString, for: .fetchWeather)
    }
    
    private func performRequest (with urlString: String, for caller: Caller) {
        if let url = URL (string: urlString ) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                switch caller {
                case .getCityName:
                    if error != nil {
                        self.delegate?.didFailWithError(error: error!)
                        return
                    }
                    if let safeData = data {
                        if let location = self.parseCityJSON(safeData) {
                            delegate?.didGetCityName(location)
                        }
                    }
                case .fetchWeather:
                    if error != nil {
                        self.delegate?.didFailWithError(error: error!)
                        return
                    }
                    if let safeData = data {
                        if let weather = self.parseJSON(safeData) {
                            delegate?.didUpdateWeather(weather)
                        }
                    }
                case .getCoordinates:
                    if error != nil {
                        self.delegate?.didFailWithError(error: error!)
                        return
                    }
                    if let safeData = data {
                        if let location = self.parseCityJSON(safeData) {
                            delegate?.didGetCoordinates(location)
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    private func parseCityJSON(_ data: Data) -> CityData? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode( CityData.self, from: data)
            return decodedData
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    private func parseJSON(_ data: Data) -> WeatherData? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode( WeatherData.self, from: data)
            return decodedData
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    
}
