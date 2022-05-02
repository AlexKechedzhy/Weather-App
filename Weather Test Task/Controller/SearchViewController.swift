//
//  SearchViewController.swift
//  Weather Test Task
//
//  Created by Alex173 on 20.04.2022.
//

import UIKit
import Combine

protocol SearchViewControllerDelegate: AnyObject {
    func didTapSearchToForecastButton(lat: Double, lon: Double, name: String)
    func didTapReturnButtonSearchVC()
}

class SearchViewController: UIViewController {
    
    private enum Constants {
        static let forecastToSearch = "forecastToSearch"
        static let forecastToMap = "forecastToMap"
        static let tableViewCellReuseIdentifier = "suggestionCell"
        static let tableViewCellnib = "SuggestionTableViewCell"
    }
    
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var tableView: UITableView!
    
    private var searchService: SearchService = SearchService()
    private var cancellable: AnyCancellable?
    private var citiesSuggestion: SearchData? {
        didSet {
            self.tableView.reloadData()
        }
    }
    weak var delegate: SearchViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .white
        textField.delegate = self
        setupPublishers()
        setupTableView()
    }
    
    private func setupPublishers() {
        let publisher = NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self.textField)
        self.cancellable = publisher.compactMap {
            ($0.object as! UITextField)
                .text?
                .addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        }.debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .flatMap { city in
                self.searchService.fetchData(text: city)
                    .catch { _ in Empty()}
                    .map { $0 }
            }.sink {
                self.citiesSuggestion = $0
            }
    }
    
    //MARK: - UIButtons' methods
    
    @IBAction private func backToForecastButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        delegate?.didTapReturnButtonSearchVC()
    }
    
    @IBAction private func searchToForecastButtonPressed(_ sender: UIButton) {
        if let lat = citiesSuggestion?.features[0].geometry.coordinates[1],
           let lon = citiesSuggestion?.features[0].geometry.coordinates[0],
           let name = citiesSuggestion?.features[0].properties.name {
            self.navigationController?.popViewController(animated: true)
            delegate?.didTapSearchToForecastButton(lat: lat, lon: lon, name: name)
        }
    }
}

// MARK: - TableView Methods

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citiesSuggestion?.features.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.tableViewCellReuseIdentifier, for: indexPath) as? SuggestionTableViewCell else { return UITableViewCell() }
        if let properties = citiesSuggestion?.features[indexPath.row].properties {
            let city = properties.name
            let country = properties.country
            cell.cityAndCountryLabel.text = "\(city), \(country)"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let lat = citiesSuggestion?.features[indexPath.row].geometry.coordinates[1],
           let lon = citiesSuggestion?.features[indexPath.row].geometry.coordinates[0],
           let name = citiesSuggestion?.features[indexPath.row].properties.name {
            self.navigationController?.popViewController(animated: true)
            delegate?.didTapSearchToForecastButton(lat: lat, lon: lon, name: name)
        }
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: Constants.tableViewCellnib, bundle: nil), forCellReuseIdentifier: Constants.tableViewCellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
