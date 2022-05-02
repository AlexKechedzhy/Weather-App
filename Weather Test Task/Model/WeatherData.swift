//
//  WeatherData.swift
//  Weather Test Task
//
//  Created by Alex173 on 15.04.2022.
//

import Foundation

struct WeatherData: Codable {
    let current: Current
    let hourly: [Hourly]
    let daily: [Daily]
}

struct Current: Codable {
    let dt: Int
    let temp: Double
    let wind_speed: Double
    let wind_deg: Int
    let weather: [Weather]
}

struct Hourly: Codable {
    let dt: Int
    let temp: Double
    let humidity: Int
    let weather: [Weather]
}

struct Daily: Codable {
    let dt: Int
    let temp: Temp
    let humidity: Int
    let weather: [Weather]
}

struct Temp: Codable {
    let min: Double
    let max: Double
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}
