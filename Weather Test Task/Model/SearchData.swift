//
//  SearchData.swift
//  Weather Test Task
//
//  Created by Alex173 on 22.04.2022.
//

import Foundation

struct SearchData: Decodable {
    let features: [Features]
}

struct Features: Decodable {
    let properties: Properties
    let geometry: Geometry
}

struct Properties: Decodable {
    let name: String
    let country: String
    let label: String
}

struct Geometry: Decodable {
    let coordinates: [Double]
}




