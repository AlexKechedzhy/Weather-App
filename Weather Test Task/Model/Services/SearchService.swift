//
//  SearchService.swift
//  Weather Test Task
//
//  Created by Alex173 on 22.04.2022.
//

import Foundation
import Combine

class SearchService {
    
    enum Constants: String {
        case APIKey = "32514940-c245-11ec-ad6a-3fa3ee009ece"
        case baseURL = "https://app.geocodeapi.io/api/v1/autocomplete?"
    }
    
    func fetchData(text: String) -> AnyPublisher<SearchData, Error> {
        guard let url = URL(string: "\(Constants.baseURL.rawValue)apikey=\(Constants.APIKey.rawValue)&text=\(text)&size=10#") else {
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
