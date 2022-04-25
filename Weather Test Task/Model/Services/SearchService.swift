//
//  SearchService.swift
//  Weather Test Task
//
//  Created by Alex173 on 22.04.2022.
//

import Foundation
import Combine

class SearchService {
    let APIKey = "32514940-c245-11ec-ad6a-3fa3ee009ece"
    let baseURL = "https://app.geocodeapi.io/api/v1/autocomplete?"
    
    func fetchData(text: String) -> AnyPublisher<SearchData, Error> {
        print("Fetch Data method got called!!!!!")
        guard let url = URL(string: "\(baseURL)apikey=\(APIKey)&text=\(text)&size=10#") else {
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
