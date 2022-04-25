//
//  SearchViewController.swift
//  Weather Test Task
//
//  Created by Alex173 on 20.04.2022.
//

import UIKit
import Combine

class SearchViewController: UIViewController {
    

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var testLabel: UILabel!
    
    private var searchService: SearchService = SearchService()
    private var cancellable: AnyCancellable?
    var citiesSuggestion: SearchData? {
        didSet {
            self.tableView.reloadData()
        }
    }
    var selectedCityName: String?
    
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        if segue.identifier == "searchToForecast" {
            let destinationVC = segue.destination as! ForecastViewController
            destinationVC.weatherRequestSource = .fromSearchView
            destinationVC.selectedCityName = selectedCityName
        }
    }
    
//MARK: - UIButtons' methods
    
    @IBAction func backToForecastButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "backToForecast", sender: self)
    }
    
    @IBAction func searchToForecastButtonPressed(_ sender: UIButton) {
        if let topSuggestion = citiesSuggestion?.features[0].properties.name {
            selectedCityName = topSuggestion
            performSegue(withIdentifier: "searchToForecast", sender: self)
        }
    }
}


// MARK: - TableView Methods

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citiesSuggestion?.features.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "suggestionCell", for: indexPath) as! SuggestionTableViewCell
        if let properties = citiesSuggestion?.features[indexPath.row].properties {
            let city = properties.name
            let country = properties.country
            cell.cityAndCountryLabel.text = "\(city), \(country)"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCityName = citiesSuggestion?.features[indexPath.row].properties.name
        performSegue(withIdentifier: "searchToForecast", sender: self)
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: "SuggestionTableViewCell", bundle: nil), forCellReuseIdentifier: "suggestionCell")
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
