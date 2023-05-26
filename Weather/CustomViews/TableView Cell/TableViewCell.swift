//
//  TableViewCell.swift
//  Weather
//
//  Created by Pooyan on 01/01/2023.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    static let identifier = "TableViewCell"
    
    @IBOutlet weak var cityNameLabel: UILabel!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        backgroundColor = .darkBlue
        cityNameLabel.textColor = .systemGray2
    }
}

// MARK: - Setup Functions
extension TableViewCell {
    
    func setup(with data: CityNameModel) {
        cityNameLabel.text = data.name
    }
}
