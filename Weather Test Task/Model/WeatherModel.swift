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
            return "ic_white_day_thunder"
        case 300...399:
            return "ic_white_day_rain"
        case 500...599:
            return "ic_white_day_shower"
        case 600...699:
            return "cloud.snow"
        case 700...799:
            return "cloud.fog"
        case 800:
            return "ic_white_day_bright"
        case 801...810:
            return "ic_white_day_cloudy"
        default:
            return "ic_white_day_cloudy"
        }
    }
        func getWindDirectionName(windDirection: Int) -> String {
            switch windDirection {
            case 0...22:
                return "icon_wind_s"
            case 23...67:
                return "icon_wind_ws"
            case 68...112:
                return "icon_wind_w"
            case 113...157:
                return "icon_wind_wn"
            case 158...202:
                return "icon_wind_n"
            case 203...247:
                return "icon_wind_ne"
            case 248...292:
                return "icon_wind_e"
            case 293...337:
                return "icon_wind_se"
            case 337...359:
                return "icon_wind_s"
            default:
            return "icon_wind_sn"
            }
        }
}
