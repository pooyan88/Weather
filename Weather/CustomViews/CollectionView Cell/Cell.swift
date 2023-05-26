//
//  Cell.swift
//  Weather
//
//  Created by Pooyan on 28/12/2022.
//

import UIKit

class Cell: UICollectionViewCell {
    
    static let identifier = "Cell"
    static let cellsMargins: CGFloat = 15
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tempretureLabel: UILabel!
    @IBOutlet weak var weatherStatusLabel: UILabel!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var weatherStatusImage: UIImageView!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupLayout()
    }
}

// MARK: - Setup Functions
extension Cell {
    
    private func setupLayout() {
        layer.cornerRadius = .largeCornerRadius
        contentView.backgroundColor = .superDarkBlue
    }
    
    func setup(at indexPath: IndexPath, data: WeatherResponse) {
        setupLoadingIndicatorAnimate(isAnimate: data.isLoadingNeedsToAppear ?? true)
        tempretureLabel.text = data.current.tempC?.description
        weatherStatusLabel.text = data.current.condition?.text
        countryNameLabel.text = data.location.name
        if let url = data.current.condition?.icon {
            weatherStatusImage.download(from: url)
        } else {
            weatherStatusImage.image = UIImage(systemName: "questionmark.app")
        }
        if indexPath.row % 2 != 0 {
            layer.position.y += Cell.cellsMargins
        }
    }
    
    private func setupLoadingIndicatorAnimate(isAnimate: Bool) {
        loadingIndicator.hidesWhenStopped = true
        isAnimate ? loadingIndicator.startAnimating() : loadingIndicator.stopAnimating()
        if isAnimate {
            hideComponents()
        } else {
            showComponents()
        }
    }
    
    private func hideComponents() {
        tempretureLabel.isHidden = true
        weatherStatusImage.isHidden = true
        weatherStatusLabel.isHidden = true
    }
    
    private func showComponents() {
        tempretureLabel.isHidden = false
        weatherStatusImage.isHidden = false
        weatherStatusLabel.isHidden = false
    }
}
