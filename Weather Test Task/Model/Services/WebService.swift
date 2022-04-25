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
    
    let apiKey = "144ae1233d3463be4dc6dd11edb813c8"
    let weatherURL = "https://api.openweathermap.org/data/2.5/onecall?exclude=alerts,minutely&units=metric"
    let cityURL = "https://api.openweathermap.org/data/2.5/weather?"
    let cityAPIKey = "144ae1233d3463be4dc6dd11edb813c8"

    func getCityName(latitude: Double, longitude: Double) {
        let urlString = "\(cityURL)lat=\(String(format:"%.3f", latitude))&lon=\(String(format:"%.3f", longitude))&appid=\(cityAPIKey)"
        print(urlString)
        performRequest(with: urlString, for: "getCityName")
    }
    
    func getCoordinates(city: String) {
        let urlString = "\(cityURL)q=\(city)&appid=\(cityAPIKey)&units=metric"
        performRequest(with: urlString, for: "getCoordinates")
    }
    
    func fetchWeather (latitude: Double, longitude: Double) {
        let urlString = "\(weatherURL)&lat=\(String(format:"%.3f", latitude))&lon=\(String(format:"%.3f", longitude))&appid=\(apiKey)"
        performRequest(with: urlString, for: "fetchWeather")
    }
    
    func performRequest (with urlString: String, for caller: String) {
        if let url = URL (string: urlString ) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                switch caller {
                case "getCityName":
                    if error != nil {
                        self.delegate?.didFailWithError(error: error!)
                        return
                    }
                    if let safeData = data {
                        if let location = self.parseCityJSON(safeData) {
                            delegate?.didGetCityName(location)
                        }
                    }
                case "fetchWeather":
                    if error != nil {
                        self.delegate?.didFailWithError(error: error!)
                        return
                    }
                    if let safeData = data {
                        if let weather = self.parseJSON(safeData) {
                            delegate?.didUpdateWeather(weather)
                        }
                    }
                case "getCoordinates":
                    if error != nil {
                        self.delegate?.didFailWithError(error: error!)
                        return
                    }
                    if let safeData = data {
                        if let location = self.parseCityJSON(safeData) {
                            delegate?.didGetCoordinates(location)
                        }
                    }
                default: return
                }
            }
            task.resume()
        }
    }
    
    func parseCityJSON(_ data: Data) -> CityData? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode( CityData.self, from: data)
            return decodedData
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    func parseJSON(_ data: Data) -> WeatherData? {
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
