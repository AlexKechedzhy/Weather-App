//
//  Webservice.swift
//  Weather Test Task
//
//  Created by Alex173 on 15.04.2022.
//

import Foundation
import Combine

protocol WebServiceDelegate {
    func didUpdateWeather(_ weather: WeatherData)
    func didFailWithError(error: Error?)
}

struct WebService {
    
    var delegate: WebServiceDelegate?
    
    private enum Constants {
        static let apiKey = "144ae1233d3463be4dc6dd11edb813c8"
        static let weatherURL = "https://api.openweathermap.org/data/2.5/onecall?exclude=alerts,minutely&units=metric"
        static let andLat = "&lat="
        static let andLon = "&lon="
        static let andAppID = "&appid="
        static let doubleFormat = "%.3f"
    }
    
    func fetchCombineWeather(latitude: Double, longitude: Double) -> AnyPublisher<WeatherData, Error> {
        guard let url = URL(string: "\(Constants.weatherURL)\(Constants.andLat)\(String(format:Constants.doubleFormat, latitude))\(Constants.andLon)\(String(format: Constants.doubleFormat, longitude))\(Constants.andAppID)\(Constants.apiKey)") else {
            delegate?.didFailWithError(error: nil)
            return Empty().eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .map {$0.data}
            .decode(type: WeatherData.self, decoder: JSONDecoder())
            .map {$0.self}
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    
    
}
