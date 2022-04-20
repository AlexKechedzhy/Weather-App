//
//  WeatherModel.swift
//  Weather Test Task
//
//  Created by Alex173 on 18.04.2022.
//

import Foundation

struct WeatherModel {
    
    func getImageSystemName(conditionId: Int) -> String {
        switch conditionId {
        case 200...299:
            return "cloud.bolt.rain"
        case 300...399:
            return "cloud.drizzle"
        case 500...599:
            return "cloud.rain"
        case 600...699:
            return "cloud.snow"
        case 700...799:
            return "cloud.fog"
        case 800:
            return "sun.max"
        case 801...810:
            return "cloud"
        default:
            return "cloud"
        }
    }
        func getWindDirectionName(windDirection: Int) -> String {
            switch windDirection {
            case 0...22:
                return "arrow.down"
            case 23...67:
                return "arrow.down.left"
            case 68...112:
                return "arrow.left"
            case 113...157:
                return "arrow.up.left"
            case 158...202:
                return "arrow.up"
            case 203...247:
                return "arrow.up.right"
            case 248...292:
                return "arrow.right"
            case 293...337:
                return "arrow.down.right"
            case 337...359:
                return "arrow.down"
            default:
            return "arrow.down"
            }
        }
}
