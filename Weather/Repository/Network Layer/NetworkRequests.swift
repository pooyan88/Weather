//
//  Requests.swift
//  Weather
//
//  Created by Pooyan on 15/03/2023.
//

import Foundation


class NetworkRequests {
    
    enum MyError: Error {
        case serverError
        case urlError
        case decodeError
    }
    
    static let shared = NetworkRequests()
    
    private init() {}
}

// MARK: - API Calls
extension NetworkRequests {
    
    func fetchCityData(with text: String, completion: @escaping (Result<[CityNameModel], MyError>)->()) {
        let url = "https://api.weatherapi.com/v1/search.json?key=ec51c5f169d2409b85293311210511&q=" + text
        baseRequest(with: url, type: [CityNameModel].self, completion: completion)
    }
    
    func fetchWeatherData(with city: String, completion: @escaping (Result<WeatherResponse, MyError>)->()) {
        let url = "https://api.weatherapi.com/v1/forecast.json?key=ec51c5f169d2409b85293311210511&q=\(city)&days=1&aqi=no&alerts=no"
        baseRequest(with: url, type: WeatherResponse.self, completion: completion)
    }
}

// MARK: - Base Requests
extension NetworkRequests {
    
    private func baseRequest<T:Decodable>(with url: String, type: T.Type, completion: @escaping (Result<T, MyError>)->()) {
        guard let url = URL(string: url) else {
            completion(.failure(.urlError))
            print("URL Error")
            return
        }
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(.serverError))
                print("server error")
                return
            }
            do {
                let result = try JSONDecoder().decode(type, from: data)
                completion(.success(result))
                print(result)
            } catch {
                completion(.failure(.decodeError))
                print("decode error")
            }
        }
        task.resume()
    }
}
