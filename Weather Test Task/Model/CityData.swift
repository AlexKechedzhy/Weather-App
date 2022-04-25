//
//  CityData.swift
//  Weather Test Task
//
//  Created by Alex173 on 19.04.2022.
//

import Foundation

struct CityData: Decodable {
    let coord: Coord
    let name: String
}

struct Coord: Decodable {
    let lon: Double
    let lat: Double
}
