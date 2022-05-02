//
//  SearchService.swift
//  Weather Test Task
//
//  Created by Alex173 on 22.04.2022.
//

import Foundation
import Combine

class SearchService {
    
    private enum Constants {
        static let APIKey = "32514940-c245-11ec-ad6a-3fa3ee009ece"
        static let baseURL = "https://app.geocodeapi.io/api/v1/autocomplete?"
        static let andApiKey = "apikey="
        static let andText = "&text="
        static let andSize = "&size=10#"
    }
    
    func fetchData(text: String) -> AnyPublisher<SearchData, Error> {
        guard let url = URL(string: "\(Constants.baseURL)\(Constants.andApiKey)\(Constants.APIKey)\(Constants.andText)\(text)\(Constants.andSize)") else {
            fatalError("The URL is invalid")
        }
        print(url)
        return URLSession.shared.dataTaskPublisher(for: url)
            .map{ $0.data }
            .decode(type: SearchData.self, decoder: JSONDecoder())
            .map{ $0 }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
