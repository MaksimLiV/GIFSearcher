//
//  APIConfig.swift.swift
//  GIFSearcher
//
//  Created by Maksim Li on 28/04/2025.
//

import Foundation

struct APIConfig {
#if DEBUG
    static let apiKey = SecretAPIKey.key
#else
    static let apiKey = PublicAPIKey.key
#endif
    static let baseURL = "https://api.giphy.com/v1"
}
