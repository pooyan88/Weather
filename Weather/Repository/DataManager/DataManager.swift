//
//  DataModel.swift
//  Weather
//
//  Created by Pooyan on 06/03/2023.
//

import Foundation

class DataManager {
    
   static let shared = DataManager()
    let shitKey1 = "ab1"
    let shitKey2 = "ab2"

    private init () {}
    
    func saveCities(cities: [CityNameModel]) {
        let encodedCities = try? JSONEncoder().encode(cities)
        UserDefaults.standard.set(encodedCities, forKey: shitKey1)
    }
    
    func loadCities() -> [CityNameModel] {
        if let data = UserDefaults.standard.data(forKey: shitKey1) {
            if let decodedData = try? JSONDecoder().decode([CityNameModel].self, from: data) {
                return decodedData
            }
        }
        return []
    }
    
    func saveWeatherCondition(data: [WeatherResponse]) {
        let encodedWeatherConditions = try? JSONEncoder().encode(data)
        UserDefaults.standard.set(encodedWeatherConditions, forKey: shitKey2)
    }
    
    func loadWeatherCondition() -> [WeatherResponse] {
        if let data = UserDefaults.standard.data(forKey: shitKey2) {
            if let decodedData = try? JSONDecoder().decode([WeatherResponse].self, from: data) {
                return decodedData
            }
        }
        return []
    }
}
