//
//  Repository.swift
//  Weather
//
//  Created by Pooyan on 21/04/2023.
//

import Foundation

class Repository {
    
    static let shared = Repository()
    
    func getWeather(city: String, comple: @escaping (WeatherResponse)->()) {
        if isCityDateExpired(city: city) {
            getWeatherFromAPI(city: city, comple: comple)
        } else {
            getWeatherFromDataBase(city: city, comple: comple)
        }
    }
    
    func getWeatherFromAPI(city: String, comple: @escaping (WeatherResponse)->()) {
        NetworkRequests.shared.fetchWeatherData(with: city) { response in
            switch response {
            case .success(var data):
                print("success")
                data.date = Date()
                comple(data)
            case.failure(.decodeError):
                print("decode error")
            case.failure(.serverError):
                print("server error")
            case .failure(.urlError):
                print("url error")
            }
        }
    }
    
    func getWeatherFromDataBase(city: String, comple: @escaping (WeatherResponse)->()) {
        if let weather = DataManager.shared.loadWeatherCondition(for: city) {
            comple(weather)
        }
    }
    
    func isCityDateExpired(city: String) -> Bool {
        let weather = DataManager.shared.loadWeatherCondition(for: city)
        if let savedDate = weather?.date, Date() >= savedDate.withAddedHours(hours: 1) {
            print("city date did expire")
            return true
        }
        print("city date did not expire")
        return false
    }
    
    func updateCityDate(city: String) {
        var weather = DataManager.shared.loadWeatherCondition(for: city)
        weather?.date = Date()
        
    }
}



