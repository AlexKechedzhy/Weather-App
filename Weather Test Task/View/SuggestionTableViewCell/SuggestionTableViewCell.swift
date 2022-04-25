//
//  SuggestionTableViewCell.swift
//  Weather Test Task
//
//  Created by Alex173 on 22.04.2022.
//

import UIKit

class SuggestionTableViewCell: UITableViewCell {

    @IBOutlet weak var cityAndCountryLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
