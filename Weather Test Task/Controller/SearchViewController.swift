//
//  SearchViewController.swift
//  Weather Test Task
//
//  Created by Alex173 on 20.04.2022.
//

import UIKit
import Combine

protocol SearchViewControllerDelegate: AnyObject {
    func didTapSearchToForecastButton(city: String)
}

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
    
    @IBAction func backToForecastButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true)
    }
    
    @IBAction func searchToForecastButtonPressed(_ sender: UIButton) {
        if let topSuggestion = citiesSuggestion?.features[0].properties.name {
            self.navigationController?.popViewController(animated: true)
            delegate?.didTapSearchToForecastButton(city: topSuggestion)
            self.dismiss(animated: true)
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
        if let selectedCityName = citiesSuggestion?.features[indexPath.row].properties.name {
            self.navigationController?.popViewController(animated: true)
            delegate?.didTapSearchToForecastButton(city: selectedCityName)
            self.dismiss(animated: true)
        }
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
