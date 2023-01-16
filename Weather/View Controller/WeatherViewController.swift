//
//  ViewController.swift
//  Weather
//
//  Created by Pooyan on 28/12/2022.
//

import UIKit

class WeatherListViewController: UIViewController {
    
    @IBOutlet weak var searchCityNameSearchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var thirdLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var locationButton: UIButton!
    
    var cityNameArray:[CityNameModel] = [] {
        didSet {
            refreshTableView()
        }
    }
    
    var weatherConditions:[WeatherResponse] {
        set {
            let encodedWeatherConditions = try? JSONEncoder().encode(newValue)
            UserDefaults.standard.set(encodedWeatherConditions, forKey: "WeatherConditions")
            
        } get {
            if let data = UserDefaults.standard.data(forKey: "WeatherConditions") {
                if let decodedData = try? JSONDecoder().decode([WeatherResponse].self, from: data) {
                    return decodedData
                }
            }
            return []
        }
    }
    
    let cellsMargins:CGFloat = 15
    var selectedCollectionViewCell = 0
    var selectedTableViewCell = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupLocationButton()
        setupSearchCityNameSearchBar()
        setupSecondLabel()
        setupThirdLabel()
        setupTableView()
        setupTableViewHidden(isHidden: true)
    }
    
    func saveCity(at indexPath: IndexPath) {
        let selectedCity = cityNameArray[indexPath.row]
        let encodedCityName = try? JSONEncoder().encode(selectedCity)
        UserDefaults.standard.set(encodedCityName, forKey: "City")
        print("CITY DATA DID SAVE: \(selectedCity)")
        
    }
    
    func loadCity() -> CityNameModel? {
        print(#function)
        if let data = UserDefaults.standard.object(forKey: "City") as? Data {
            if let decodedData = try? JSONDecoder().decode(CityNameModel.self, from: data) {
                print("data did load: \(decodedData)")
                print("City Name : \(decodedData.name)")
                return decodedData
            }
        }
        return nil
    }
    
    func setupTableViewHidden(isHidden: Bool) {
        tableView.isHidden = isHidden
        print("setupTableViewHidden \(isHidden)")
    }
    
    func refreshTableView() {
        DispatchQueue.main.async {
            self.setupTableViewHidden(isHidden: self.cityNameArray.isEmpty)
            self.tableView.reloadData()
        }
    }
    
    func refreshCollectionView() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            print("CollectionView Updated")
        }
    }
    
    func setupTableView() {
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 10
        tableView.backgroundColor = UIColor(hex: "#222245")
    }
    
    func weatherConditionRequestAndUpdateData() {
        fetchingWeatherResponse { weatherConditions in
            print("WEATHER CONDITIONS: \(weatherConditions)")
            self.weatherConditions.append(weatherConditions)
            print("Request Sent And Data Updated")
            self.refreshCollectionView()
        }
    }
}


//MARK: - CALLED API
extension WeatherListViewController {
    
    func fetchingCityNameData(with text: String, completion:@escaping ([CityNameModel]) -> ()) {
        let url = "https://api.weatherapi.com/v1/search.json?key=ec51c5f169d2409b85293311210511&q=" + text
        guard let url = URL(string: url) else {
            print("Failed to convert url: \(url)")
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("something went wrong")
                return
            }
            var result: [CityNameModel]?
            do {
                result = try JSONDecoder().decode([CityNameModel].self, from: data)
            } catch {
                print("Failed to convert \(error.localizedDescription)")
            }
            if let decodedData = result {
                completion(decodedData)
            } else {
                print("Failed to parse decoded data")
            }
        }
        task.resume()
    }
    
    func fetchingWeatherResponse(completion:@escaping (WeatherResponse) -> ()) {
        let url = "https://api.weatherapi.com/v1/forecast.json?key=ec51c5f169d2409b85293311210511&q=\(loadCity()?.name ?? "tehran")&days=1&aqi=no&alerts=no"
        guard let url = URL(string: url) else {
            print("Failed to convert url: \(url)")
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("something went wrong")
                return
            }
            var result: WeatherResponse?
            do {
                result = try JSONDecoder().decode(WeatherResponse.self, from: data)
            } catch {
                print("Failed to convert \(error.localizedDescription)")
            }
            if let decodedData = result {
                completion(decodedData)
            } else {
                print("Failed to parse decoded data")
            }
        }
        task.resume()
    }
}


// MARK: - Setup Functions
extension WeatherListViewController {
    
    func setupLocationButton() {
        locationButton.backgroundColor = UIColor(hex: "#222245")
        locationButton.layer.cornerRadius = 10
        locationButton.layer.borderWidth = 1
        locationButton.layer.borderColor = UIColor.systemGray2.cgColor
        
    }
    
    func setupSearchCityNameSearchBar() {
        searchCityNameSearchBar.backgroundColor = UIColor(hex: "#222245")
        searchCityNameSearchBar.barTintColor = UIColor(hex: "#222245")
        searchCityNameSearchBar.searchTextField.backgroundColor = UIColor(hex: "#222245")
        searchCityNameSearchBar.layer.borderWidth = 1
        searchCityNameSearchBar.layer.borderColor = UIColor.systemGray2.cgColor
        searchCityNameSearchBar.layer.cornerRadius = 10
        searchCityNameSearchBar.layer.masksToBounds = true
        searchCityNameSearchBar.searchTextField.textColor = .systemGray2
        
    }
    
    func setupCollectionView() {
        collectionView.register(UINib(nibName: "Cell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.layer.cornerRadius = 10
        collectionView.backgroundColor = view.backgroundColor
    }
    
    func setupSecondLabel() {
        secondLabel.textColor = UIColor(hex: "#6C6E8C")
    }
    
    func setupThirdLabel() {
        thirdLabel.textColor = UIColor(hex: "#6C6E8C")
    }
}

// MARK: - CollectionView Functions
extension WeatherListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherConditions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! Cell
        let data = weatherConditions[indexPath.row]
        cell.tempretureLabel.text = data.current.tempC?.description
        cell.weatherStatusLabel.text = data.current.condition?.text
        cell.countryNameLabel.text = data.location.name
        if let url = data.current.condition?.icon {
            cell.weatherStatusImage.download(from: url)
        } else {
            cell.weatherStatusImage.image = UIImage(systemName: "questionmark.app")
        }
        cell.layer.cornerRadius = 25
        if indexPath.row % 2 != 0 {
            cell.layer.position.y += cellsMargins
        }
        cell.contentView.backgroundColor = UIColor(hex: "#151635")
        if selectedCollectionViewCell == indexPath.row {
            cell.contentView.backgroundColor = UIColor(hex: "#3F86DF")
        } else {
            cell.contentView.backgroundColor = UIColor(hex: "#151635")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let margins:CGFloat = 60 + cellsMargins
        let width:CGFloat = (view.frame.width - margins) / 2
        return CGSize(width: width, height: width )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellsMargins
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellsMargins
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCollectionViewCell = indexPath.row
        refreshCollectionView()
    }
}

//MARK: - TableView Functions
extension WeatherListViewController:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityNameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        cell.selectionStyle = .none
        if selectedTableViewCell == indexPath.row {
            cell.backgroundColor = UIColor(hex: "#3F86DF")
        }
        cell.cityNameLabel.textColor = .systemGray2
        cell.backgroundColor = UIColor(hex: "#222245")
        cell.cityNameLabel.text = cityNameArray[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        setupTableViewHidden(isHidden: true)
        saveCity(at: indexPath)
        weatherConditionRequestAndUpdateData()
    }
}

//MARK: - SearchBar Functions
extension WeatherListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let text = searchCityNameSearchBar.text {
            if text.count >= 3 {
                fetchingCityNameData(with: searchText) { cityNames in
                    self.cityNameArray = cityNames
                    print("!! DATA DID CHANGE !!")
                }
            }
        }
        if searchText.isEmpty == true {
            self.cityNameArray = []
            print("!! DATA DID REMOVE !!")
        }
    }
}

