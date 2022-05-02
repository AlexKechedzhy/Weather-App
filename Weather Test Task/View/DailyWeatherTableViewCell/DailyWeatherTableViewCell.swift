//
//  DailyWeatherTableViewCell.swift
//  Weather Test Task
//
//  Created by Alex173 on 18.04.2022.
//

import UIKit

class DailyWeatherCellBackView: UIView {
    var isSelected: Bool = false
    
    override var bounds: CGRect {
        didSet {
            isSelected ? addShadow() : removeShadow()
        }
    }
    
    private func addShadow() {
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 10
        self.layer.shadowOpacity = 0.25
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 0, height: 0)).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
    
    private func removeShadow() {
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 0
        self.layer.shadowOpacity = 0
        self.layer.shadowPath = .none
        self.layer.shouldRasterize = false
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}


class DailyWeatherTableViewCell: UITableViewCell {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var backView: DailyWeatherCellBackView!
    var cellIsSeleceted = false

    override func awakeFromNib() {
            super.awakeFromNib()
            setupBaseView()
        }

        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
            selected ? setupSelected() : setupBaseView()
        }
        
        private func setupSelected() {
            dayLabel.textColor = UIColor.lightBlue
            temperatureLabel.textColor = UIColor.lightBlue
            weatherImage.image = self.weatherImage.image?.withRenderingMode(.alwaysTemplate)
            weatherImage.tintColor = UIColor.lightBlue
            backgroundColor = .white
            layer.masksToBounds = false
            layer.shadowOpacity = 0.25
            layer.shadowRadius = 10
            layer.shadowOffset = CGSize(width: 0, height: 0)
            layer.shadowColor = UIColor.lightBlue?.cgColor ?? UIColor.clear.cgColor
            contentView.backgroundColor = .white
            contentView.layer.cornerRadius = 0
        }
        
        func setupBaseView() {
            dayLabel.textColor = UIColor.black
            temperatureLabel.textColor = UIColor.black
            weatherImage.tintColor = UIColor.black
            backgroundColor = .clear
            layer.masksToBounds = false
            layer.shadowOpacity = 0
            layer.shadowRadius = 0
            layer.shadowOffset = CGSize(width: 0, height: 0)
            layer.shadowColor = UIColor.clear.cgColor
            contentView.backgroundColor = .white
            contentView.layer.cornerRadius = 0
        }
    
}
