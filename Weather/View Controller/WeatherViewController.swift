//
//  ViewController.swift
//  Weather
//
//  Created by Pooyan on 28/12/2022.
//

import UIKit

class WeatherListViewController: UIViewController {
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var locationButton: UIButton!
    
    static let shared = WeatherListViewController()
    var group = DispatchGroup()
    var refreshControl = UIRefreshControl()
    var cities: [CityNameModel] = [] {
        didSet {
            refreshTableView()
        }
    }
    var weatherConditions: [WeatherResponse] {
        set {
            DataManager.shared.saveWeatherCondition(data: newValue)
        } get {
            return DataManager.shared.loadWeatherCondition()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        hideKeyboardWhenTappedAround()
        updateWeatherDataWithDelay(delay: 1)
        refreshData(loaderColor: .white)
    }
}

// MARK: - Setup Views
extension WeatherListViewController {
    
    func setupViews() {
        setupCollectionView()
        setupLocationButton()
        setupSearchBar()
        setupTableView()
        setupLoadingIndicator()
        weatherConditions.updateLoadingsState(isLoading: true)
    }
        
    func setupCollectionView() {
        collectionView.register(UINib(nibName: Cell.identifier, bundle: nil), forCellWithReuseIdentifier: Cell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.layer.cornerRadius = .regularCornerRadius
        collectionView.backgroundColor = .clear
        collectionView.addSubview(refreshControl)
    }
    
    func setupLocationButton() {
        locationButton.backgroundColor = .darkBlue
        locationButton.layer.cornerRadius = .regularCornerRadius
        locationButton.layer.borderWidth = 1
        locationButton.layer.borderColor = UIColor.systemGray2.cgColor
    }
    
    func setupSearchBar() {
        searchBar.backgroundColor = .darkBlue
        searchBar.barTintColor = .darkBlue
        searchBar.searchTextField.backgroundColor = .darkBlue
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColor.systemGray2.cgColor
        searchBar.layer.cornerRadius = .regularCornerRadius
        searchBar.layer.masksToBounds = true
        searchBar.searchTextField.textColor = .systemGray2
    }
    
    func setupTableView() {
        tableView.register(UINib(nibName: TableViewCell.identifier, bundle: nil), forCellReuseIdentifier: TableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = .regularCornerRadius
        tableView.backgroundColor = .darkBlue
        tableView.isHidden = true
    }
    
    func setupLoadingIndicatorHidden(isHidden: Bool) {
        loadingIndicator.isHidden = isHidden
        loadingIndicator.hidesWhenStopped = true
    }
    
    func setupLoadingIndicatorAnimation(isAnimate: Bool) {
        loadingIndicator.isAnimating ? loadingIndicator.startAnimating() : loadingIndicator.stopAnimating()
        loadingIndicator.hidesWhenStopped = true
    }
    
    func setupCollectionViewHidden(isHidden: Bool) {
        collectionView.isHidden = isHidden
    }
    
    func setupLoadingIndicator() {
        loadingIndicator.style = UIActivityIndicatorView.Style.large
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = .white
    }
    
    func setupLoadingIndicatorAnimate(isAnimating: Bool) {
        isAnimating ? loadingIndicator.startAnimating() : loadingIndicator.stopAnimating()
    }
    
    func showLoading() {
        setupLoadingIndicatorHidden(isHidden: false)
        setupLoadingIndicatorAnimate(isAnimating: true)
    }
    
    func hideLoading() {
        setupLoadingIndicatorHidden(isHidden: true)
        setupLoadingIndicatorAnimate(isAnimating: false)
    }
    
    func setupSearchBarWhenLoadingDisplayed() {
        searchBar.isUserInteractionEnabled = false
        searchBar.barTintColor = .black
        searchBar.backgroundColor = .black
        searchBar.searchTextField.backgroundColor = .black
    }
    
    func setupSearchBarWhenLoadingDidHide() {
        searchBar.isUserInteractionEnabled = true
        searchBar.barTintColor = .darkBlue
        searchBar.backgroundColor = .darkBlue
        searchBar.searchTextField.backgroundColor = .darkBlue
    }
}

//MARK: - Setup Actions
extension WeatherListViewController {
    
    func deleteCollectionViewCell(at indexPath: IndexPath) {
        collectionView.deleteItems(at: [indexPath])
    }
    
    @objc func pullToRefresh(_ sender: UIRefreshControl) {
        DispatchQueue.main.async { [self] in
            forceUpdateData()
            refreshCollectionView()
            group.notify(queue: .main ) { [self] in
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
                    refreshControl.endRefreshing()
                }
            }
        }
    }
    
    func refreshData(loaderColor: UIColor) {
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = loaderColor
    }
    
    func updateWeatherDataWithDelay(delay: Double = 1) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay){ [self] in
            updateWeatherData()
        }
    }
    
    func refreshTableView() {
        tableView.isHidden = cities.isEmpty
        tableView.reloadData()
    }
    
    func refreshCollectionView() {
        DispatchQueue.main.async { [self] in
            collectionView.reloadData()
            print("CollectionView Updated")
        }
    }
    
    func refreshCollectionViewCell(at indexPath: IndexPath) {
        collectionView.reloadItems(at: [indexPath])
        print("Cell \(indexPath) Updated")
    }
    
    func fetchWeatherCondition(for city: String, completion: @escaping (WeatherResponse) -> ()) {
        NetworkRequests.shared.fetchWeatherData(with: city) { response in
            switch response {
            case .success(let weather):
                completion(weather)
            case .failure(let error):
                DispatchQueue.main.async { [self] in
                    self.showNetworkError(error: error)
                }
            }
        }
    }
    
    func removeCitiesIfSearchBarIsEmpty(isSearchBarEmpty: Bool) {
        if isSearchBarEmpty {
            cities = []
            print("!! SEARCHBAR CONTENTS DID REMOVE !!")
        }
    }
    
    func searchAction(text: String) {
        if text.count >= 3 {
            NetworkRequests.shared.fetchCityData(with: text) { [self] response in
                DispatchQueue.main.async { [self] in
                    switch response {
                    case .success(let data):
                        cities = data
                    case .failure(let error):
                        showNetworkError(error: error)
                    }
                }
            }
        }
    }
    
    func updateWeatherData() {
        group.enter()
        for i in 0..<weatherConditions.count {
            let indexPath = IndexPath(item: i, section: 0)
            if let city = weatherConditions[i].location.name {
                Repository.shared.getWeather(city: city) { weatherData in
                    DispatchQueue.main.async { [self] in
                        weatherConditions[i] = weatherData
                        weatherConditions.updateLoadingsState(isLoading: false)
                        print("print DATE ==>" ,weatherConditions[i].date as Any)
                        refreshCollectionViewCell(at: indexPath)
                    }
                }
            }
        }
        group.leave()
    }
    
    func forceUpdateData() {
        for i in 0..<weatherConditions.count {
            let indexPath = IndexPath(item: i, section: 0)
            if let city = weatherConditions[i].location.name {
                fetchWeatherCondition(for: city) { [self] weatherData in
                    DispatchQueue.main.async { [self] in
                        weatherConditions[i] = weatherData
                        weatherConditions.updateLoadingsState(isLoading: false)
                        weatherConditions[i].date = Date()
                        print("print DATE ==>" ,weatherConditions[i].date as Any)
                        refreshCollectionViewCell(at: indexPath)
                    }
                }
            }
        }
    }
}

// MARK: - CollectionView Functions
extension WeatherListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherConditions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.identifier, for: indexPath) as! Cell
        cell.setup(at: indexPath, data: weatherConditions[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sideMargins: CGFloat = 60
        let margins: CGFloat = sideMargins + Cell.cellsMargins 
        let width: CGFloat = (view.frame.width - margins) / 2
        return CGSize(width: width, height: width )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Cell.cellsMargins
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Cell.cellsMargins
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        
        let context = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            
            let delete = UIAction(title: "Delete", image: UIImage(named: "trash"), identifier: nil, discoverabilityTitle: nil, attributes: .destructive, state: .off) { _ in
                print("delete button tapped")
                let index = indexPaths.first!.row
                self.weatherConditions.remove(at: index)
                collectionView.deleteItems(at: indexPaths)
            }
            return UIMenu(title: "Options", image: nil, identifier: nil, options: UIMenu.Options.displayInline, children: [delete])
        }
        return context
    }
}

//MARK: - TableView Functions
extension WeatherListViewController:UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.identifier, for: indexPath) as! TableViewCell
        cell.setup(with: cities[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.isHidden = true
        let city = cities[indexPath.row].name
        fetchWeatherCondition(for: city) { [self] weatherData in
            var weather = weatherData
            weather.date = Date()
            weatherConditions.append(weather)
            weatherConditions.updateLoadingsState(isLoading: false)
            refreshCollectionView()
        }
    }
}

//MARK: - SearchBar Functions
extension WeatherListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        removeCitiesIfSearchBarIsEmpty(isSearchBarEmpty: searchText.isEmpty)
        searchAction(text: searchText)
    }
}

