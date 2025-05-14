//
//  NetworkService.swift
//  GIFSearcher
//
//  Created by Maksim Li on 29/04/2025.
//

import Foundation
import Alamofire

protocol NetworkServiceProtocol {
    func request<T: Decodable>(endpoint: Endpoint, completion: @escaping (Result<T, NetworkError>) -> Void)
}

class NetworkService: NetworkServiceProtocol {
    private let session: Session
    
    init(session: Session = .default) {
        self.session = session
    }
    
    func request<T: Decodable>(endpoint: Endpoint, completion: @escaping (Result<T, NetworkError>) -> Void) {
        
        if !NetworkMonitor.shared.isConnected {
            completion(.failure(.noInternetConnection))
            return
        }
        
        guard let urlRequest = endpoint.makeURLRequest() else {
            completion(.failure(.invalidURL))
            return
        }
        
        session.request(urlRequest)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let decodedObject):
                    completion(.success(decodedObject))
                    
                case .failure(let error):
                    if let urlError = error.underlyingError as? URLError {
                        completion(.failure(.unknown(urlError)))
                        return
                    }
                    
                    if let afError = error.asAFError {
                        switch afError {
                        case .invalidURL:
                            completion(.failure(.invalidURL))
                        case .responseValidationFailed(let reason):
                            if case .unacceptableStatusCode(let code) = reason {
                                completion(.failure(.serverError(code)))
                            } else {
                                completion(.failure(.invalidResponse))
                            }
                        case .responseSerializationFailed:
                            completion(.failure(.decodingError(error)))
                        default:
                            completion(.failure(.unknown(error)))
                        }
                        return
                    }
                    
                    completion(.failure(.unknown(error)))
                }
            }
    }
}
