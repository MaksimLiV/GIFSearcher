//
//  GiphyService.swift
//  GIFSearcher
//
//  Created by Maksim Li on 29/04/2025.
//

import Foundation

protocol GiphyServiceProtocol {
    func searchGifs(query: String, limit: Int, offset: Int, completion: @escaping (Result<GIFResponse, NetworkError>) -> Void)
    func getTrendingGifs(limit: Int, offset: Int, completion: @escaping (Result<GIFResponse, NetworkError>) -> Void)
    func getGifById(id: String, completion: @escaping (Result<GIF, NetworkError>) -> Void)
}

class GiphyService: GiphyServiceProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func searchGifs(query: String, limit: Int, offset: Int, completion: @escaping (Result<GIFResponse, NetworkError>) -> Void) {
        let endpoint = GiphyEndpoint.search(query: query, limit: limit, offset: offset)
        networkService.request(endpoint: endpoint, completion: completion)
    }
    
    func getTrendingGifs(limit: Int, offset: Int, completion: @escaping (Result<GIFResponse, NetworkError>) -> Void) {
        let endpoint = GiphyEndpoint.trending(limit: limit, offset: offset)
        networkService.request(endpoint: endpoint, completion: completion)
    }
    
    func getGifById(id: String, completion: @escaping (Result<GIF, NetworkError>) -> Void) {
        struct SingleGifResponse: Codable {
            let data: GIF
        }
        
        let endpoint = GiphyEndpoint.byId(id: id)
        networkService.request(endpoint: endpoint) { (result: Result<SingleGifResponse, NetworkError>) in
            switch result {
            case .success(let response):
                completion(.success(response.data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
