//
//  GiphyEndpoint.swift
//  GIFSearcher
//
//  Created by Maksim Li on 29/04/2025.
//

import Foundation

enum GiphyEndpoint: Endpoint {
    case search(query: String, limit: Int, offset: Int)
    case trending(limit: Int, offset: Int)
    case byId(id: String)
    
    var baseURL: String {
        return APIConfig.baseURL
    }
    
    var path: String {
        switch self {
        case .search:
            return "/gifs/search"
        case .trending:
            return "/gifs/trending"
        case .byId(let id):
            return "/gifs/\(id)"
        }
    }
    
    var queryItems: [URLQueryItem] {
        var items = [URLQueryItem(name: "api_key", value: APIConfig.apiKey)]
        
        switch self {
        case .search(let query, let limit, let offset):
            items.append(contentsOf: [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "limit", value: "\(limit)"),
                URLQueryItem(name: "offset", value: "\(offset)")
            ])
        case .trending(let limit, let offset):
            items.append(contentsOf: [
                URLQueryItem(name: "limit", value: "\(limit)"),
                URLQueryItem(name: "offset", value: "\(offset)")
            ])
        case .byId:
            break
        }
        
        return items
    }
    
    var method: HTTPMethod {
        return .get
    }
}
