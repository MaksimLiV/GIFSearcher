//
//  GIFResponse.swift
//  GIFSearcher
//
//  Created by Maksim Li on 28/04/2025.
//

import Foundation

struct GIFResponse: Codable {
    let data: [GIF]
    let pagination: Pagination
    let meta: Meta
    
    struct Pagination: Codable {
        let totalCount: Int
        let count: Int
        let offset: Int
        
        enum CodingKeys: String, CodingKey {
            case totalCount = "total_count"
            case count
            case offset
        }
    }
    
    struct Meta: Codable {
        let status: Int
        let msg: String
        let responseId: String
        
        enum CodingKeys: String, CodingKey {
            case status
            case msg
            case responseId = "response_id"
        }
    }
}
