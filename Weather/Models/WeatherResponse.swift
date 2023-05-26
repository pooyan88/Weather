//
//  WeatherResponse.swift
//  Weather
//
//  Created by Pooyan on 08/01/2023.
//

import Foundation

struct WeatherResponse: Codable {
    var location: Location
    var current: Current
    var forecast: Forecast
    var isLoadingNeedsToAppear: Bool?
    var date: Date?
}

// MARK: - Current
struct Current: Codable {
    
    var tempC: Double?
    let condition: Condition?
 
    enum CodingKeys: String, CodingKey {
        case tempC = "temp_c"
        case condition
    }
}

// MARK: - Condition
struct Condition: Codable {
    let text: String?
    let icon: String?
    let code: Int?
}

// MARK: - Forecast
struct Forecast: Codable {
    let forecastday: [Forecastday]
}

// MARK: - Forecastday
struct Forecastday: Codable {
    
    let date: String?
    let day: Day?
    let hour: [Hour]

    enum CodingKeys: String, CodingKey {
        case date, day, hour
    }
}

// MARK: - Day
struct Day: Codable {
    
    let maxtempC, mintempC, avgtempC: Double?
    let condition: Condition?

    enum CodingKeys: String, CodingKey {
        case maxtempC = "maxtemp_c"
        case mintempC = "mintemp_c"
        case avgtempC = "avgtemp_c"
        case condition
    }
}

// MARK: - Hour
struct Hour: Codable {
 
    let time: String?
    let tempC: Double?
    let condition: Condition?
    
    enum CodingKeys: String, CodingKey {
        case time
        case tempC = "temp_c"
        case condition
    }
}

// MARK: - Location
struct Location: Codable {
    
    var name, region, country: String?
    let lat, lon: Double?

    enum CodingKeys: String, CodingKey {
        case name, region, country, lat, lon
    }
}

extension [WeatherResponse] {
    
    mutating func updateLoadingsState(isLoading: Bool) {
        for i in 0..<self.count {
            self[i].isLoadingNeedsToAppear = isLoading
        }
    }
    
   mutating func updateDate() {
        for i in 0..<self.count {
            self[i].date = Date()
        }
    }
}
