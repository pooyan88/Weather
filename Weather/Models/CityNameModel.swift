//
//  CityNameModel.swift
//  Weather
//
//  Created by Pooyan on 08/01/2023.
//

import UIKit

struct CityNameModel: Codable {
    let id: Int
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
    let url: String
}

