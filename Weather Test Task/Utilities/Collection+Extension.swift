//
//  Collection+Extension.swift
//  Weather Test Task
//
//  Created by Alex173 on 02.05.2022.
//

import Foundation

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
