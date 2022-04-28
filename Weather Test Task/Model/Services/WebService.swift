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
    func didFailWithError(error: Error)
}


struct WebService {
    
    var delegate: WebServiceDelegate?
    
    enum Constants: String {
        case apiKey = "144ae1233d3463be4dc6dd11edb813c8"
        case weatherURL = "https://api.openweathermap.org/data/2.5/onecall?exclude=alerts,minutely&units=metric"
        case cityURL = "https://api.openweathermap.org/data/2.5/weather?"
    }
    
    func fetchCombineWeather(latitude: Double, longitude: Double) -> AnyPublisher<WeatherData, Error> {
        guard let url = URL(string: "\(Constants.weatherURL.rawValue)&lat=\(String(format:"%.3f", latitude))&lon=\(String(format:"%.3f", longitude))&appid=\(Constants.apiKey.rawValue)") else {
            fatalError()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .map {$0.data}
            .decode(type: WeatherData.self, decoder: JSONDecoder())
            .map {$0.self}
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    
    
}
