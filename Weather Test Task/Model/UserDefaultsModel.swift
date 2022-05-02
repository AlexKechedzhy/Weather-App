//
//  UserDefaultsModel.swift
//  Weather Test Task
//
//  Created by Alex173 on 30.04.2022.
//

import Foundation

class UserDefaultsModel {
    @UserDefaultsWrapper(key: "locationAlertHasBeenPresented", defaultValue: false)
    static var locationAlertHasBeenPresented: Bool
}
