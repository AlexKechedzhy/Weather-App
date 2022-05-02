//
//  UIView+Extension.swift
//  Weather Test Task
//
//  Created by Alex173 on 01.05.2022.
//

import UIKit

extension UIView {
    func addShadow(color: CGColor, opacity: Float, radius: Double, offset: (Double, Double)){
        self.layer.masksToBounds = false
        self.layer.shadowColor = color
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
        self.layer.shadowOffset = CGSize(width: offset.0, height: offset.1)
    }
}
