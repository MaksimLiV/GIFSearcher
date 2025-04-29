//
//  NetworkError.swift
//  GIFSearcher
//
//  Created by Maksim Li on 29/04/2025.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case decodingError(Error)
    case serverError(Int)
    case noInternetConnection
    case unknown(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .invalidResponse:
            return "Received an invalid response from the server."
        case .invalidData:
            return "Received invalid data from the server."
        case .decodingError(let error):
            return "Data decoding error: \(error.localizedDescription)"
        case .serverError(let statusCode):
            return "Server error with code: \(statusCode)"
        case .noInternetConnection:
            return "No internet connection."
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}
